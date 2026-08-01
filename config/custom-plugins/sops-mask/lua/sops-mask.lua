-- Mask secret values in sops-decrypted buffers.
--
-- sops decrypts into a temp file and hands it to $EDITOR, which means every
-- secret is on screen at once. This paints `*` over every value, leaving the
-- last 4 characters readable, and reveals the line the cursor is on.
-- Text is untouched: yanking, editing, and saving see the real value.
local M = {}

local ns = vim.api.nvim_create_namespace("sops_mask")
local KEEP = 4

-- Values worth masking: scalars on the right of `key:` and inside sequences.
-- Nested mappings are not captured, so their keys stay visible.
local QUERY = [[
	(block_mapping_pair value: (flow_node) @v)
	(block_mapping_pair value: (block_node (block_scalar) @v))
	(block_sequence_item (flow_node) @v)
]]

local function value_ranges(buf)
	local ok, parser = pcall(vim.treesitter.get_parser, buf, "yaml")
	if not ok or not parser then
		return {}
	end
	local query = vim.treesitter.query.parse("yaml", QUERY)
	local out = {}
	for _, node in query:iter_captures(parser:parse()[1]:root(), buf) do
		local start_row, start_col, end_row, end_col = node:range()
		-- Keep a block scalar's `|`/`>` header visible; mask its body.
		if node:type() == "block_scalar" then
			start_row, start_col = start_row + 1, -1 -- -1: start at the indent
		end
		if start_row <= end_row then
			out[#out + 1] = { start_row, start_col, end_row, end_col }
		end
	end
	return out
end

-- sops strips its own `sops:` metadata before handing the file over, so the
-- buffer holds nothing that marks it as a secret. What it does do is decrypt
-- into a throwaway directory of its own: `$TMPDIR/<random>/<original name>`.
-- `SOPS_MASK=1` forces the mask on for anything sops does differently.
local function is_sops_buffer(buf)
	if vim.env.SOPS_MASK then
		return true
	end
	local tmp = (vim.uv.os_tmpdir() or "/tmp"):gsub("/+$", "")
	local dir = vim.api.nvim_buf_get_name(buf):match("^" .. vim.pesc(tmp) .. "/([^/]+)/[^/]+$")
	return dir ~= nil and (dir:match("^%d+$") or dir:match("^sops")) ~= nil
end

-- One overlay extmark per character, rather than one covering the whole value.
-- A single wide overlay stops at the edge of the screen line and leaves the
-- rest of a wrapped value in the clear; concealing instead leaves blank rows
-- behind. Per character costs marks but is the only variant that both hides
-- everything and keeps the layout the file really has.
-- ponytail: bounded by the visible screen; revisit if redraws feel slow.
local function mask(buf, row, text, col)
	local chars = vim.str_utf_pos(text)
	for i, byte in ipairs(chars) do
		local char = text:sub(byte, (chars[i + 1] or #text + 1) - 1)
		vim.api.nvim_buf_set_extmark(buf, ns, row, col + byte - 1, {
			virt_text = { { ("*"):rep(vim.api.nvim_strwidth(char)), "Comment" } },
			virt_text_pos = "overlay",
		})
	end
end

local function render(buf)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	if not vim.b[buf].sops_mask then
		return
	end
	-- Only what is on screen needs marks, and only a visible buffer has a
	-- cursor line to reveal.
	local cursor, top, bottom = -1, 0, vim.api.nvim_buf_line_count(buf) - 1
	if vim.api.nvim_get_current_buf() == buf then
		cursor = vim.api.nvim_win_get_cursor(0)[1] - 1
		top, bottom = vim.fn.line("w0") - 1, vim.fn.line("w$") - 1
	end
	for _, range in ipairs(value_ranges(buf)) do
		local start_row, start_col, end_row, end_col = unpack(range)
		for row = math.max(start_row, top), math.min(end_row, bottom) do
			local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
			local indent = (line:find("%S") or 1) - 1
			local from = (row == start_row and start_col >= 0) and start_col or indent
			-- `KEY=value` inside a block scalar: the name is not the secret.
			local name = line:sub(from + 1):match("^[%w_.]+=")
			if name then
				from = from + #name
			end
			-- Only the tail of each line stays readable.
			local to = math.max(from, (row == end_row and end_col or #line) - KEEP)
			if row ~= cursor and to > from then
				mask(buf, row, line:sub(from + 1, to), from)
			end
		end
	end
end

local function attach(buf)
	if vim.b[buf].sops_mask ~= nil or not is_sops_buffer(buf) then
		return
	end
	vim.b[buf].sops_mask = true
	vim.api.nvim_create_autocmd({
		"CursorMoved",
		"CursorMovedI",
		"TextChanged",
		"TextChangedI",
		"InsertLeave",
		"WinScrolled",
		"WinResized",
	}, {
		buffer = buf,
		callback = function()
			render(buf)
		end,
	})
	render(buf)
end

function M.setup()
	vim.api.nvim_create_user_command("SopsMaskToggle", function()
		vim.b.sops_mask = not vim.b.sops_mask
		render(0)
	end, { desc = "Toggle sops secret masking" })

	-- Unpatterned and on several events: sops names its temp file after the
	-- original, but filetype detection is not worth betting the mask on.
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter", "FileType" }, {
		callback = function(args)
			attach(args.buf)
		end,
	})
end

return M
