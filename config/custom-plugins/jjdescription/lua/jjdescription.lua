local M = {}

function M.setup()
	-- Use gitcommit treesitter parser for jjdescription files
	vim.treesitter.language.register("gitcommit", "jjdescription")

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "jjdescription",
		callback = function()
			local m = function(hl, pat)
				vim.fn.matchadd(hl, pat, 20)
			end
			-- JJ: comments
			m("Comment", "^JJ:.*$")
			-- Everything after "JJ: ignore-rest" is a comment
			m("Comment", [[JJ: ignore-rest\_.*]])
			-- Change ID and Commit ID values
			m("Identifier", [[\(Change\|Commit\) ID: \zs\w\+]])
			-- File status indicator (MADRC)
			m("Type", [[^JJ:\s\+\zs[MADRC]\ze\s]])
			-- File paths by status
			m("diffAdded", [[^JJ:\s\+A\s\+\zs.*$]])
			m("diffChanged", [[^JJ:\s\+M\s\+\zs.*$]])
			m("diffRemoved", [[^JJ:\s\+D\s\+\zs.*$]])
			m("diffFile", [[^JJ:\s\+[RC]\s\+\zs.*$]])
		end,
	})
end

return M
