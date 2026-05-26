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

	cache[bufnr] = true
end

-- table.insert requires 1 <= pos <= #t + 1; clamp to survive index drift
-- caused by merges / rename gaps in the reconstructed history.
local function clamp_ins(t, pos)
	if pos < 1 then
		return 1
	end
	if pos > #t + 1 then
		return #t + 1
	end
	return pos
end

-- "hotness" = churn: how many times each *current* line has been edited
-- across history. We replay the file's diffs oldest -> newest, maintaining a
-- per-line edit count that tracks lines as they move. A line replaced N times
-- accumulates heat N; a line added once and never touched stays at 1, even if
-- it is the most recent change. This is the opposite of recency/newness.
local function run_churn(bufnr)
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

		-- --first-parent --reverse gives a linear oldest->newest patch stream
		-- whose hunks, applied in order, reconstruct the current file.
		-- -U0 drops context lines so hunk headers alone drive the bookkeeping.
		vim.system(
			{ "git", "log", "--first-parent", "--reverse", "--format=", "-p", "-U0", "--no-color", "--", file },
			{ cwd = dir, text = true },
			function(log_out)
				if log_out.code ~= 0 then
					return
				end

				local heat = {}
				-- net lines added by prior hunks within the *current* commit;
				-- each commit's hunk numbers are relative to its own parent, so
				-- this resets at every commit (marked by a `diff --git` line).
				local offset = 0

				for line in log_out.stdout:gmatch("[^\n]+") do
					if line:match("^diff %-%-git") then
						offset = 0
					end
					-- @@ -old_start[,old_len] +new_start[,new_len] @@
					local os_, ol_, nl_ = line:match("^@@ %-(%d+),?(%d*) %+%d+,?(%d*) @@")
					if os_ then
						os_ = tonumber(os_)
						ol_ = (ol_ == "") and 1 or tonumber(ol_)
						nl_ = (nl_ == "") and 1 or tonumber(nl_)

						if ol_ == 0 then
							-- pure insertion: new lines go after old line os_
							local ins = clamp_ins(heat, os_ + offset + 1)
							for k = 0, nl_ - 1 do
								table.insert(heat, ins + k, 1)
							end
						else
							-- deletion / replacement: drop the old lines, carry
							-- their hottest value forward so a hot region stays hot
							local idx = os_ + offset
							local carry = 0
							for _ = 1, ol_ do
								if heat[idx] ~= nil then
									if heat[idx] > carry then
										carry = heat[idx]
									end
									table.remove(heat, idx)
								end
							end
							local val = carry + 1
							local base = clamp_ins(heat, idx)
							for k = 0, nl_ - 1 do
								table.insert(heat, base + k, val)
							end
						end

						offset = offset + (nl_ - ol_)
					end
				end

				vim.schedule(function()
					if not enabled then
						return
					end
					if not vim.api.nvim_buf_is_valid(bufnr) then
						return
					end
					-- align to current buffer: uncommitted/extra lines fall back
					-- to cold (1) rather than inheriting a neighbour's heat.
					local n = vim.api.nvim_buf_line_count(bufnr)
					local dense = {}
					for i = 1, n do
						dense[i] = heat[i] or 1
					end
					apply_heat(bufnr, dense)
				end)
			end
		)
	end)
end

-- oil heat = how often each entry has been committed (its churn), not its
-- mtime (which is just newness). One git log over the directory tallies
-- commits per file.
local function run_oil_heat(bufnr)
	local ok, oil = pcall(require, "oil")
	if not ok then
		return
	end
	local dir = oil.get_current_dir(bufnr)
	if not dir then
		return
	end

	vim.system({ "git", "log", "--format=", "--name-only", "--", "." }, { cwd = dir, text = true }, function(out)
		if out.code ~= 0 then
			return
		end

		-- tally commits per basename (unique within a single directory)
		local counts = {}
		for line in out.stdout:gmatch("[^\n]+") do
			local base = line:match("([^/]+)$")
			if base then
				counts[base] = (counts[base] or 0) + 1
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
	end)
end

local function clear_buf(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	cache[bufnr] = nil
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
