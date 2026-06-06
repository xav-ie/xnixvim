-- blink.cmp source: spell corrections from vim.fn.spellsuggest. A zero-dep,
-- license-clean stand-in for ribru17/blink-cmp-spell (which ships no license).
-- Self-gated to buffers where 'spell' is on (the prose filetypes set in
-- extraConfigLua.nix), so it never fires while editing code.

--- @type blink.cmp.Source
local source = {}

function source.new(opts)
	return setmetatable({ max = (opts or {}).max_entries or 5 }, { __index = source })
end

function source:enabled()
	return vim.wo.spell
end

-- LSP CompletionItemKind.Text — hardcoded to avoid requiring blink internals.
local TEXT_KIND = 1

function source:get_completions(ctx, callback)
	local word = ctx.line:sub(1, ctx.cursor[2]):match("[%a']+$")
	local items = {}
	for i, suggestion in ipairs(word and vim.fn.spellsuggest(word, self.max) or {}) do
		items[i] = {
			label = suggestion,
			kind = TEXT_KIND,
			sortText = ("%05d"):format(i), -- preserve spellsuggest's ranking
		}
	end
	-- Re-query on every edit: the suggestion set depends on the whole (mis)spelt
	-- word, so blink must not cache-and-filter a stale list.
	callback({ items = items, is_incomplete_backward = true, is_incomplete_forward = true })
end

return source
