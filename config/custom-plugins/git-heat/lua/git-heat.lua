local M = {}

local ns = vim.api.nvim_create_namespace("git_heat")
local NUM_BUCKETS = 20
local COLD = { r = 0x3a, g = 0x3a, b = 0x4a }
local HOT = { r = 0xff, g = 0x3a, b = 0x8e }
local SIGN = "▎"

local enabled = true
local cache = {} -- bufnr -> true (marks already placed)

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

local function apply_marks(bufnr, timestamps)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

	if #timestamps == 0 then
		return
	end

	-- find min/max
	local min_ts, max_ts = math.huge, -math.huge
	for _, ts in ipairs(timestamps) do
		if ts < min_ts then
			min_ts = ts
		end
		if ts > max_ts then
			max_ts = ts
		end
	end

	local range = max_ts - min_ts
	for lnum, ts in ipairs(timestamps) do
		local t
		if range == 0 then
			t = 0.5 -- single-commit file: mid-range
		else
			t = (ts - min_ts) / range
		end
		-- quantize to bucket
		local bucket = math.floor(t * (NUM_BUCKETS - 1) + 0.5) + 1
		if bucket > NUM_BUCKETS then
			bucket = NUM_BUCKETS
		end

		pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, lnum - 1, 0, {
			sign_text = SIGN,
			sign_hl_group = hl_groups[bucket],
			priority = 1, -- low priority so gitsigns wins
		})
	end

	cache[bufnr] = true
end

local function run_blame(bufnr)
	local file = get_file(bufnr)
	if not file then
		return
	end

	local dir = vim.fn.fnamemodify(file, ":h")

	-- check git-tracked
	vim.system({ "git", "ls-files", "--error-unmatch", file }, { cwd = dir }, function(ls_out)
		if ls_out.code ~= 0 then
			return -- not tracked
		end

		vim.system({ "git", "blame", "--line-porcelain", file }, { cwd = dir, text = true }, function(blame_out)
			if blame_out.code ~= 0 then
				return
			end

			local timestamps = {}
			local now = os.time()
			local line_idx = 0

			for line in blame_out.stdout:gmatch("[^\n]+") do
				-- each porcelain block starts with a hash line containing the line number
				local orig_line, final_line = line:match("^%x+ (%d+) (%d+)")
				if final_line then
					line_idx = tonumber(final_line)
				end

				local ts_str = line:match("^author%-time (%d+)")
				if ts_str then
					local ts = tonumber(ts_str)
					-- uncommitted lines have ts=0 or very small; treat as newest
					if ts == 0 then
						ts = now
					end
					timestamps[line_idx] = ts
				end
			end

			-- convert sparse table to dense array
			if line_idx == 0 then
				return
			end
			local dense = {}
			for i = 1, line_idx do
				dense[i] = timestamps[i] or now -- fallback uncommitted
			end

			vim.schedule(function()
				if enabled then
					apply_marks(bufnr, dense)
				end
			end)
		end)
	end)
end

local function run_oil_heat(bufnr)
	local ok, oil = pcall(require, "oil")
	if not ok then
		return
	end
	local dir = oil.get_current_dir(bufnr)
	if not dir then
		return
	end

	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local timestamps = {}
	local has_any = false

	for lnum = 1, line_count do
		local entry = oil.get_entry_on_line(bufnr, lnum)
		if entry then
			local stat = vim.uv.fs_stat(dir .. entry.name)
			if stat then
				timestamps[lnum] = stat.mtime.sec
				has_any = true
			end
		end
	end

	if not has_any then
		return
	end

	-- rank-based coloring: sort by mtime, assign gradient evenly
	local sorted = {}
	for lnum, ts in pairs(timestamps) do
		sorted[#sorted + 1] = { lnum = lnum, ts = ts }
	end
	table.sort(sorted, function(a, b)
		return a.ts < b.ts
	end)

	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	local n = #sorted
	for rank, entry in ipairs(sorted) do
		local t = n == 1 and 0.5 or (rank - 1) / (n - 1)
		local bucket = math.floor(t * (NUM_BUCKETS - 1) + 0.5) + 1
		if bucket > NUM_BUCKETS then
			bucket = NUM_BUCKETS
		end
		pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, entry.lnum - 1, 0, {
			sign_text = SIGN,
			sign_hl_group = hl_groups[bucket],
			priority = 200,
		})
	end
	cache[bufnr] = true
end

local function clear_buf(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	cache[bufnr] = nil
end

local function run_heat(bufnr)
	if is_oil(bufnr) then
		run_oil_heat(bufnr)
	else
		run_blame(bufnr)
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

function M.setup()
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

	-- cleanup on buffer wipe
	vim.api.nvim_create_autocmd("BufWipeout", {
		group = group,
		callback = function(ev)
			cache[ev.buf] = nil
		end,
	})
end

return M
