-- xdusk lualine theme. Lualine's "auto" option resolves
-- `lualine.themes.<vim.g.colors_name>` first, so dropping this file inside
-- the xdusk plugin's runtimepath wires it up without any extra setup.
--
-- Section a (mode chip): vibrant mode color on the deep-plum code bg.
-- Section b: deep wine — warm counterpoint to the plum main bar.
-- Section c: deep-plum (bg_code) main bar — explicit bg avoids falling
-- through to xdusk's StatusLine highlight (which is base02 bright blue).

local p = require("xdusk.palette")

local chip_fg = p.bg_code -- dark plum reads cleanly against the bright mode colors

local function mode(bg)
	return {
		a = { bg = bg, fg = chip_fg, gui = "bold" },
		b = { bg = p.statusline_b, fg = p.base05 },
		c = { bg = p.bg_code, fg = p.base08 }, -- amber/gold text on deep plum
	}
end

return {
	normal = mode(p.base0D), -- violet
	insert = mode(p.base0B), -- green
	visual = mode(p.base08), -- amber
	replace = mode(p.base0E), -- pink
	command = mode(p.base0C), -- yellow
	terminal = mode(p.base09), -- cyan-blue
	inactive = {
		a = { bg = "NONE", fg = p.base03, gui = "bold" },
		b = { bg = "NONE", fg = p.base03 },
		c = { bg = "NONE", fg = p.base03 },
	},
}
