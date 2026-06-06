-- blink.cmp source: surface an active LuaSnip choiceNode's options as
-- completion items. A blink port of L3MON4D3/cmp-luasnip-choice, updated for
-- LuaSnip's current API (per-buffer active_choice_nodes, get_current_choices
-- returns newline-joined strings).
--
-- Accepting an item flips the choiceNode via `set_choice` rather than inserting
-- text: :execute deliberately skips blink's default text-edit implementation,
-- leaving LuaSnip to re-render the node.

local function get_luasnip()
	local ok, ls = pcall(require, "luasnip")
	if not ok then
		return nil
	end
	return ls
end

--- @type blink.cmp.Source
local source = {}

function source.new(opts)
	return setmetatable({ opts = opts or {} }, { __index = source })
end

-- Only offer items while sitting on an active choiceNode.
function source:enabled()
	local ls = get_luasnip()
	return ls ~= nil and ls.choice_active()
end

function source:get_completions(_, callback)
	local items = {}
	local ls = get_luasnip()
	if ls then
		local ok, choices = pcall(ls.get_current_choices)
		if ok and choices then
			local kind = require("blink.cmp.types").CompletionItemKind.Snippet
			for index, docstring in ipairs(choices) do
				-- docstring may span multiple lines; use the first non-empty line as
				-- the menu label and keep the full text for the docs preview.
				local label = docstring:gsub("\n.*", "")
				if label == "" then
					label = "choice " .. index
				end
				items[index] = {
					label = label,
					kind = kind,
					-- Nothing is inserted on accept (see :execute); keep the edit empty.
					insertText = "",
					-- Stash the 1-based choice index for :execute to read.
					index = index,
					-- Preserve LuaSnip's order; blink would otherwise sort by label.
					sortText = string.format("%05d", index),
					documentation = { kind = "plaintext", value = docstring },
				}
			end
		end
	end
	callback({
		items = items,
		is_incomplete_backward = false,
		is_incomplete_forward = false,
	})
end

-- Selecting an item switches the choiceNode instead of inserting text: we call
-- the callback without invoking default_implementation, so blink applies no
-- text edit.
function source:execute(_, item, callback, _default_implementation)
	local ls = get_luasnip()
	if ls and item.index then
		pcall(ls.set_choice, item.index)
	end
	callback()
end

return source
