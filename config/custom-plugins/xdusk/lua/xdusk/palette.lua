-- xdusk — a vibrant dark colorscheme: violet + amber accents over a
-- transparent (terminal-defined) base. Best in a truecolor terminal
-- (`:set termguicolors`); a 256-color fallback is provided via `p.cterm`.
--
-- The 16 base slots follow the base16 convention so the core editor and
-- syntax groups are generated coherently; the named accents below cover
-- the plugin-specific tuning layered on top.

local p = {}

-- base16 slots --------------------------------------------------------------
p.base00 = "NONE" -- background (transparent / terminal-defined)
p.base01 = "#603090" -- darker bg: selections, current line, UI accent (violet)
p.base02 = "#1060ee" -- selection background (blue)
p.base03 = "#a090a0" -- comments, invisibles (muted mauve)
p.base04 = "#a0a0ff" -- line numbers, fold column (periwinkle)
p.base05 = "#e0e0e0" -- default foreground (light grey)
p.base06 = "#00ff00" -- light foreground (green)
p.base07 = "#a0a000" -- lightest foreground (olive)
p.base08 = "#FFB20F" -- variables, tags, errors (amber)
p.base09 = "#00a0f0" -- numbers, constants, booleans (cyan-blue)
p.base0A = "#BE620A" -- types, classes (burnt orange)
p.base0B = "#00E756" -- strings (green)
p.base0C = "#FFD242" -- special, regex, escapes (yellow)
p.base0D = "#9A5FEB" -- functions, methods, headings (violet)
p.base0E = "#ff3a8e" -- keywords, operators (pink)
p.base0F = "#f06949" -- punctuation, delimiters (coral)

-- extended accents ----------------------------------------------------------
p.bg_code = "#200020" -- inline literals / code-block background (deep plum)
p.bg_header = "#200030" -- markdown heading background
p.bullet = "#E07153" -- markdown list bullet (terracotta)

p.menu_bg = "#282828" -- popup menu background
p.menu_fg = "#ebdbb2" -- popup menu foreground
p.menu_sel_bg = "#504945" -- popup menu selection background

p.border = "#a89984" -- floating window border
p.diag_quote = "#61afef" -- quoted text inside diagnostic floats

p.red = "#ff0000" -- hard red: deleted diff lines / inline removals
p.delete_fg = "#ff4400" -- inline delete foreground (red-orange)
p.white = "White" -- scrollbar thumb

-- gruvbox-derived palette for the completion menu kind icons ----------------
p.gruv_fg = "#fbf1c7" -- cream foreground used on all kind chips
p.gruv_red = "#fb4934"
p.gruv_green = "#b8bb26"
p.gruv_yellow = "#d79921"
p.gruv_blue = "#458588"
p.gruv_purple = "#b16286"
p.gruv_aqua = "#8ec07c"
p.gruv_cyan = "#83a598" -- also used for fuzzy-match text
p.gruv_orange = "#fe8019"

-- 256-color fallback. Nearest xterm-256 index for each color above, so the
-- theme degrades gracefully in terminals without truecolor. base00 stays
-- "NONE" to preserve transparency in 256-color mode too.
p.cterm = {
	["NONE"] = "NONE",
	["White"] = 15,
	["#603090"] = 60, -- base01
	["#1060ee"] = 27, -- base02
	["#a090a0"] = 247, -- base03
	["#a0a0ff"] = 147, -- base04
	["#e0e0e0"] = 254, -- base05
	["#00ff00"] = 46, -- base06
	["#a0a000"] = 142, -- base07
	["#FFB20F"] = 214, -- base08
	["#00a0f0"] = 39, -- base09
	["#BE620A"] = 130, -- base0A
	["#00E756"] = 41, -- base0B
	["#FFD242"] = 221, -- base0C
	["#9A5FEB"] = 98, -- base0D
	["#ff3a8e"] = 204, -- base0E
	["#f06949"] = 203, -- base0F
	["#200020"] = 233, -- bg_code
	["#200030"] = 234, -- bg_header
	["#E07153"] = 167, -- bullet
	["#282828"] = 235, -- menu_bg
	["#ebdbb2"] = 187, -- menu_fg
	["#504945"] = 239, -- menu_sel_bg
	["#a89984"] = 138, -- border
	["#61afef"] = 75, -- diag_quote
	["#ff0000"] = 196, -- red
	["#ff4400"] = 202, -- delete_fg
	["#fbf1c7"] = 230, -- gruv_fg
	["#fb4934"] = 203, -- gruv_red
	["#b8bb26"] = 142, -- gruv_green
	["#d79921"] = 172, -- gruv_yellow
	["#458588"] = 66, -- gruv_blue
	["#b16286"] = 132, -- gruv_purple
	["#8ec07c"] = 108, -- gruv_aqua
	["#83a598"] = 108, -- gruv_cyan
	["#fe8019"] = 208, -- gruv_orange
}

return p
