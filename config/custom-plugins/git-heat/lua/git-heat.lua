local M = {}

local ns = vim.api.nvim_create_namespace("git_heat")
local NUM_BUCKETS = 20
local COLD = { r = 0x3a, g = 0x3a, b = 0x4a }
local HOT = { r = 0xff, g = 0x3a, b = 0x8e }
local SIGN = "▎"

-- skip the history walk + per-line signs on very large files: the gradient is
-- useless at that scale and the work is expensive. Overridable via setup().
local MAX_LINES = 5000

local enabled = true

-- committed-heat memo: filepath -> { head = sha, heat = {committed vector} }.
-- The churn binary only produces different output when the file's git history
-- changes, so a cheap `git rev-parse HEAD` gates the expensive walk: same HEAD
-- means the committed vector is identical and we reuse it across reopens.
local churn_cache = {}

local function lerp(a, b, t)
	return math.floor(a + (b - a) * t + 0.5)
end

local function bucket_color(i)
	local t = (i - 1) / (NUM_BUCKETS - 1)
	local r = lerp(COLD.r, HOT.r, t)
	local g = lerp(COLD.g, HOT.g, t)
	local b = lerp(COLD.b, HOT.b, t)
	return string.format("#%02x%02x%02x", r, g, b)
end

local hl_groups = {}
for i = 1, NUM_BUCKETS do
	local name = "GitHeat" .. i
	vim.api.nvim_set_hl(0, name, { fg = bucket_color(i) })
	hl_groups[i] = name
end

local function is_oil(bufnr)
	return vim.bo[bufnr].filetype == "oil"
end

local function skip_buf(bufnr)
	local bt = vim.bo[bufnr].buftype
	if bt ~= "" then
		return true
	end
	local ft = vim.bo[bufnr].filetype
	if ft == "fugitive" or ft == "help" or ft == "qf" then
		return true
	end
	return false
end

local function get_file(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return nil
	end
	return name
end

-- map per-line edit counts onto the sign gradient. heat values are >= 1
-- (every existing line was added at least once). churn is power-law
-- distributed, so we map on a log scale to spread the gradient usefully.
local function apply_heat(bufnr, heat, priority)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

	if #heat == 0 then
		return
	end

	local max_heat = 1
	for _, h in ipairs(heat) do
		if h > max_heat then
			max_heat = h
		end
	end
	local denom = math.log(max_heat)

	for lnum, h in ipairs(heat) do
		local t
		if denom <= 0 then
			t = 0 -- every line equally cold (single edit each)
		else
			t = math.log(h) / denom
		end
		local bucket = math.floor(t * (NUM_BUCKETS - 1) + 0.5) + 1
		if bucket < 1 then
			bucket = 1
		end
		if bucket > NUM_BUCKETS then
			bucket = NUM_BUCKETS
		end

		pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, lnum - 1, 0, {
			sign_text = SIGN,
			sign_hl_group = hl_groups[bucket],
			priority = priority or 1, -- low priority so gitsigns wins
		})
	end
end

-- path to the git-heat-churn binary, injected by setup() from Nix
local churn_bin = "git-heat-churn"

-- "hotness" = churn: how many times each *current* line has been edited across
-- history. The git-heat-churn binary (gitoxide) walks first-parent history,
-- diffs each version of the file against the previous one, and tracks a
-- per-line edit count as lines move. A line replaced N times accumulates heat
-- ~N; a line added once and never touched stays at 1, even if it is the most
-- recent change. This is the opposite of recency/newness. It prints one
-- integer per current line and exits non-zero for untracked / non-repo files.
-- paint a committed-heat vector onto the current buffer. uncommitted/extra
-- lines fall back to cold (1) rather than inheriting a neighbour's heat.
local function align_and_apply(bufnr, committed)
	if not enabled then
		return
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	local n = vim.api.nvim_buf_line_count(bufnr)
	local dense = {}
	for i = 1, n do
		dense[i] = committed[i] or 1
	end
	apply_heat(bufnr, dense)
end

local function run_churn(bufnr)
	local file = get_file(bufnr)
	if not file then
		return
	end

	-- only real files on disk have git history worth walking. synthetic buffer
	-- names (e.g. Himalaya's "Himalaya/threads [...]") resolve to non-existent
	-- paths whose parent dir doesn't exist, which makes vim.system below throw
	-- ENOENT on cwd. filereadable also skips brand-new BufNewFile buffers, which
	-- aren't tracked yet and have no churn anyway.
	if vim.fn.filereadable(file) == 0 then
		return
	end

	-- the churn walk and per-line signs don't pay off on huge files
	if vim.api.nvim_buf_line_count(bufnr) > MAX_LINES then
		return
	end

	local dir = vim.fn.fnamemodify(file, ":h")

	-- cheap HEAD lookup gates the expensive churn walk: a cache hit for the same
	-- HEAD reuses the committed vector without spawning the churn binary.
	vim.system({ "git", "-C", dir, "rev-parse", "HEAD" }, { text = true }, function(rev)
		local head = (rev.code == 0) and vim.trim(rev.stdout) or nil

		local cached = churn_cache[file]
		if cached and head and cached.head == head then
			vim.schedule(function()
				align_and_apply(bufnr, cached.heat)
			end)
			return
		end

		vim.system({ churn_bin, file }, { cwd = dir, text = true }, function(out)
			if out.code ~= 0 then
				return -- untracked, not a repo, or the binary is unavailable
			end

			local heat = {}
			for line in out.stdout:gmatch("[^\n]+") do
				local n = tonumber(line)
				if not n then
					return -- unexpected output; skip rather than paint wrong heat
				end
				heat[#heat + 1] = n
			end
			if #heat == 0 then
				return
			end

			if head then
				churn_cache[file] = { head = head, heat = heat }
			end

			vim.schedule(function()
				align_and_apply(bufnr, heat)
			end)
		end)
	end)
end

-- oil heat = how often each entry has been committed (its churn), not its
-- mtime (which is just newness). One git log over the directory tallies
-- commits per entry.
local function run_oil_heat(bufnr)
	local ok, oil = pcall(require, "oil")
	if not ok then
		return
	end
	local dir = oil.get_current_dir(bufnr)
	if not dir then
		return
	end

	-- --relative prints paths relative to `dir`, so the first path component is
	-- the direct child (the oil entry) a change belongs to. Tallying by that
	-- component avoids basename collisions with files in nested subdirectories
	-- and gives directory entries the aggregate churn of everything beneath.
	vim.system(
		{ "git", "log", "--relative", "--format=", "--name-only", "--", "." },
		{ cwd = dir, text = true },
		function(out)
			if out.code ~= 0 then
				return
			end

			local counts = {}
			for line in out.stdout:gmatch("[^\n]+") do
				local child = line:match("^[^/]+")
				if child then
					counts[child] = (counts[child] or 0) + 1
				end
			end

			vim.schedule(function()
				if not enabled then
					return
				end
				if not vim.api.nvim_buf_is_valid(bufnr) then
					return
				end

				local line_count = vim.api.nvim_buf_line_count(bufnr)
				local heat = {}
				for lnum = 1, line_count do
					local entry = oil.get_entry_on_line(bufnr, lnum)
					-- untracked / never-committed entries stay cold (1)
					heat[lnum] = (entry and counts[entry.name]) or 1
				end

				apply_heat(bufnr, heat, 200)
			end)
		end
	)
end

local function clear_buf(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

local function run_heat(bufnr)
	if is_oil(bufnr) then
		run_oil_heat(bufnr)
	else
		run_churn(bufnr)
	end
end

local function refresh_current()
	local bufnr = vim.api.nvim_get_current_buf()
	clear_buf(bufnr)
	run_heat(bufnr)
end

local function toggle()
	enabled = not enabled
	if enabled then
		-- re-run on current buffer
		refresh_current()
	else
		-- clear all buffers
		for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_valid(bufnr) then
				clear_buf(bufnr)
			end
		end
	end
	vim.notify("GitHeat " .. (enabled and "enabled" or "disabled"))
end

function M.setup(opts)
	opts = opts or {}
	if opts.churn_bin then
		churn_bin = opts.churn_bin
	end
	if opts.max_lines then
		MAX_LINES = opts.max_lines
	end

	vim.api.nvim_create_user_command("GitHeatToggle", toggle, {})
	vim.api.nvim_create_user_command("GitHeatRefresh", refresh_current, {})

	local group = vim.api.nvim_create_augroup("git_heat", { clear = true })

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = group,
		callback = function(ev)
			if not enabled then
				return
			end
			if skip_buf(ev.buf) then
				return
			end
			run_heat(ev.buf)
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		callback = function(ev)
			if not enabled then
				return
			end
			if skip_buf(ev.buf) then
				return
			end
			clear_buf(ev.buf)
			run_heat(ev.buf)
		end,
	})

	-- oil buffers: entries load asynchronously, poll until ready
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "oil",
		callback = function(ev)
			if not enabled then
				return
			end
			local function try_oil(attempts)
				if attempts <= 0 then
					return
				end
				if not vim.api.nvim_buf_is_valid(ev.buf) or not is_oil(ev.buf) then
					return
				end
				local oil_ok, oil = pcall(require, "oil")
				if not oil_ok then
					return
				end
				-- check if oil has loaded entries yet
				local entry = oil.get_entry_on_line(ev.buf, 1)
				if entry then
					run_oil_heat(ev.buf)
				else
					vim.defer_fn(function()
						try_oil(attempts - 1)
					end, 200)
				end
			end
			vim.defer_fn(function()
				try_oil(10)
			end, 100)
		end,
	})
end

return M
