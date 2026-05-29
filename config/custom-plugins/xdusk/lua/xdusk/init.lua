-- xdusk colorscheme.
--
-- Self-contained: defines the full set of editor, syntax, Treesitter, LSP and
-- common-plugin highlight groups directly (no runtime dependency). The core
-- group->slot mapping follows the base16 convention; the `overrides` table at
-- the end applies the per-plugin tuning that gives xdusk its character.
--
-- Best in a truecolor terminal (`vim.o.termguicolors = true`); a 256-color
-- fallback is derived automatically from p.cterm.

local p = require("xdusk.palette")

local M = {}

function M.setup()
	if vim.g.colors_name then
		vim.cmd("highlight clear")
	end
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.o.background = "dark"
	vim.g.colors_name = "xdusk"

	-- base16-derived core: editor, syntax, diff, git, diagnostics, treesitter,
	-- and the standard plugin groups base16 schemes conventionally define.
	local groups = {
		-- Editor ----------------------------------------------------------------
		Normal = { fg = p.base05, bg = p.base00 },
		Bold = { bold = true },
		Debug = { fg = p.base08 },
		Directory = { fg = p.base0D },
		Error = { fg = p.base08, bg = p.base00 },
		ErrorMsg = { fg = p.base08, bg = p.base00 },
		Exception = { fg = p.base08 },
		FoldColumn = { fg = p.base0C, bg = p.base00 },
		Folded = { fg = p.base03, bg = p.base01 },
		-- Search variants — mix purple/teal/orange/yellow across the four
		-- match states so each carries its own identity:
		--   IncSearch  (current match while typing /…)   → teal
		--   CurSearch  (current match after Enter)        → purple
		--   Search     (all other matches when hlsearch)  → orange
		--   MatchParen (matching paren under cursor)      → yellow
		IncSearch = { fg = p.bg_code, bg = p.base09 }, -- teal
		CurSearch = { fg = p.bg_code, bg = p.base0D }, -- purple
		Italic = { italic = true },
		Macro = { fg = p.base08 },
		MatchParen = { fg = p.bg_code, bg = p.base0C, bold = true }, -- yellow
		ModeMsg = { fg = p.base0B },
		MoreMsg = { fg = p.base0B },
		Question = { fg = p.base0D },
		Search = { fg = p.bg_code, bg = p.base0A }, -- orange
		Substitute = { fg = p.bg_code, bg = p.base0E }, -- pink (matches :s/// preview)
		SpecialKey = { fg = p.base03 },
		TooLong = { fg = p.base08 },
		Underlined = { fg = p.base08 },
		Visual = { bg = "#38154f" },
		VisualNOS = { fg = p.base08 },
		WarningMsg = { fg = p.base08 },
		WildMenu = { fg = p.base08, bg = p.base0A },
		Title = { fg = p.base0D },
		Conceal = { fg = p.base0D, bg = p.base00 },
		Cursor = { fg = p.base00, bg = p.base05 },
		NonText = { fg = p.base03 },
		LineNr = { fg = p.base04, bg = p.base00 },
		SignColumn = { fg = p.base04, bg = p.base00 },
		StatusLine = { fg = p.base05, bg = p.base02 },
		StatusLineNC = { fg = p.base04, bg = p.base01 },
		WinBar = { fg = p.base05 },
		WinBarNC = { fg = p.base04 },
		VertSplit = { fg = p.base05, bg = p.base00 },
		ColorColumn = { bg = p.base01 },
		CursorColumn = { bg = p.base01 },
		CursorLine = { bg = p.base01 },
		CursorLineNr = { fg = p.base04, bg = p.base01 },
		QuickFixLine = { bg = p.base01 },
		Pmenu = { fg = p.base05, bg = p.base01 },
		PmenuSel = { fg = p.base01, bg = p.base05 },
		TabLine = { fg = p.base03, bg = p.base01 },
		TabLineFill = { fg = p.base03, bg = p.base01 },
		TabLineSel = { fg = p.base0B, bg = p.base01 },

		-- Standard syntax -------------------------------------------------------
		Boolean = { fg = p.base09 },
		Character = { fg = p.base08 },
		Comment = { fg = p.base03 },
		Conditional = { fg = p.base0E },
		Constant = { fg = p.base09 },
		Define = { fg = p.base0E },
		Delimiter = { fg = p.base0F },
		Float = { fg = p.base09 },
		Function = { fg = p.base0D },
		Identifier = { fg = p.base08 },
		Include = { fg = p.base0D },
		Keyword = { fg = p.base0E },
		Label = { fg = p.base0A },
		Number = { fg = p.base09 },
		Operator = { fg = p.base0E },
		PreProc = { fg = p.base0A },
		Repeat = { fg = p.base0A },
		Special = { fg = p.base0C },
		SpecialChar = { fg = p.base0F },
		Statement = { fg = p.base08 },
		StorageClass = { fg = p.base0A },
		String = { fg = p.base0B },
		Structure = { fg = p.base0E },
		Tag = { fg = p.base0A },
		Todo = { fg = p.base0A, bg = p.base01 },
		Type = { fg = p.base0A },
		Typedef = { fg = p.base0A },

		-- Diff (base00 is transparent, so diff backgrounds resolve to NONE) ------
		DiffAdd = { fg = p.base0B },
		DiffChange = { bg = p.base00 },
		DiffDelete = { bg = p.base00 },
		DiffText = { bg = p.base01, bold = true },
		DiffAdded = { fg = p.base0B, bg = p.base00 },
		DiffFile = { fg = p.base08, bg = p.base00 },
		DiffNewFile = { fg = p.base0B, bg = p.base00 },
		DiffLine = { fg = p.base0D, bg = p.base00 },
		DiffRemoved = { fg = p.base08, bg = p.base00 },

		-- diffview.nvim ---------------------------------------------------------
		DiffviewNormal = { fg = p.base05, bg = p.base00 },
		DiffviewCursorLine = { bg = p.base01 },
		DiffviewSignColumn = { fg = p.base04, bg = p.base00 },
		DiffviewEndOfBuffer = { fg = p.base03 },
		DiffviewLineNr = { fg = p.base04 },
		DiffviewWinSeparator = { fg = p.base02 },
		DiffviewFilePanelTitle = { fg = p.base06, bold = true },
		DiffviewFilePanelCounter = { fg = p.base04 },
		DiffviewFilePanelFileName = { fg = p.base06 },
		DiffviewFilePanelPath = { fg = p.base04 },
		DiffviewFilePanelRootPath = { fg = p.base06, bold = true },
		DiffviewFilePanelInsertions = { fg = p.base0B, bold = true },
		DiffviewFilePanelDeletions = { fg = p.base08, bold = true },
		DiffviewStatusAdded = { fg = p.base0B, bold = true },
		DiffviewStatusUntracked = { fg = p.base0B },
		DiffviewStatusModified = { fg = p.base0A, bold = true },
		DiffviewStatusRenamed = { fg = p.base0D, bold = true },
		DiffviewStatusCopied = { fg = p.base0D },
		DiffviewStatusTypeChange = { fg = p.base0E, bold = true },
		DiffviewStatusDeleted = { fg = p.base08, bold = true },
		DiffviewStatusBroken = { fg = p.base08, bold = true },
		DiffviewStatusUnknown = { fg = p.base08 },
		DiffviewStatusUnmerged = { fg = p.base0E, bold = true },
		DiffviewDiffAddAsDelete = { fg = p.base08, bg = p.base00 },
		DiffviewDiffDelete = { fg = p.base03, bg = p.base00 },

		-- Git -------------------------------------------------------------------
		gitcommitOverflow = { fg = p.base08 },
		gitcommitSummary = { fg = p.base0B },
		gitcommitComment = { fg = p.base03 },
		gitcommitUntracked = { fg = p.base03 },
		gitcommitDiscarded = { fg = p.base03 },
		gitcommitSelected = { fg = p.base03 },
		gitcommitHeader = { fg = p.base0E },
		gitcommitSelectedType = { fg = p.base0D },
		gitcommitUnmergedType = { fg = p.base0D },
		gitcommitDiscardedType = { fg = p.base0D },
		gitcommitBranch = { fg = p.base09, bold = true },
		gitcommitUntrackedFile = { fg = p.base0A },
		gitcommitUnmergedFile = { fg = p.base08, bold = true },
		gitcommitDiscardedFile = { fg = p.base08, bold = true },
		gitcommitSelectedFile = { fg = p.base0B, bold = true },
		GitGutterAdd = { fg = p.base0B, bg = p.base00 },
		GitGutterChange = { fg = p.base0D, bg = p.base00 },
		GitGutterDelete = { fg = p.base08, bg = p.base00 },
		GitGutterChangeDelete = { fg = p.base0E, bg = p.base00 },

		-- vim-fugitive :Git status view. Defaults link Header/Heading/Modifier
		-- to Label/PreProc/Type — all of which resolve to base0A (burnt
		-- orange), so everything reads as "dark brown". Spread across the
		-- palette so each row carries semantic color (matching arete-ish).
		fugitiveHeader = { fg = p.base0D, bold = true }, -- "Head:", "Help:", "Pull:" — violet
		fugitiveHelpTag = { fg = p.base0F }, -- "g?" help shortcuts — coral (warm red-orange)
		fugitiveUntrackedHeading = { fg = p.base0E, bold = true }, -- "Untracked" — pink
		fugitiveUnstagedHeading = { fg = p.base08, bold = true }, -- "Unstaged" — amber
		fugitiveStagedHeading = { fg = p.base0B, bold = true }, -- "Staged" — green
		fugitiveUntrackedModifier = { fg = p.base0E }, -- "?" — pink (matches Untracked heading)
		fugitiveUnstagedModifier = { fg = p.base08 }, -- "M/A/D" — amber (needs action)
		fugitiveStagedModifier = { fg = p.base0B }, -- staged — green (ready)
		fugitiveHash = { fg = p.base09 }, -- commit hashes — cyan-blue
		fugitiveSymbolicRef = { fg = p.base09 }, -- branch names ("main") — cyan-blue
		fugitiveCount = { fg = p.base09 }, -- "(1)", "(6)" counts — cyan-blue

		-- Spelling --------------------------------------------------------------
		SpellBad = { undercurl = true, sp = p.base08 },
		SpellLocal = { undercurl = true, sp = p.base0C },
		SpellCap = { undercurl = true, sp = p.base0D },
		SpellRare = { undercurl = true, sp = p.base0E },

		-- Diagnostics -----------------------------------------------------------
		-- Hue split mirrors arete: warm = severe (error amber, warn pink),
		-- cool = advisory (info violet, hint green). Hint deliberately uses
		-- base0B green instead of base0C yellow because amber+yellow read as
		-- the same hue in undercurl form.
		-- Two emphasis tiers: error+warn get a tinted virtual-text bg ("loud");
		-- info+hint stay backgroundless ("quiet"). All four still differ by fg
		-- color, sign color, and undercurl color so the level is unambiguous.
		DiagnosticError = { fg = p.base08 },
		DiagnosticWarn = { fg = p.base0E },
		DiagnosticInfo = { fg = p.base0D },
		DiagnosticHint = { fg = p.base0B },
		DiagnosticUnderlineError = { undercurl = true, sp = p.base08 },
		-- Both the legacy "Warning/Information" names and the modern "Warn/Info"
		-- names are defined; some plugins still reference the old ones.
		DiagnosticUnderlineWarning = { undercurl = true, sp = p.base0E },
		DiagnosticUnderlineWarn = { undercurl = true, sp = p.base0E },
		DiagnosticUnderlineInformation = { undercurl = true, sp = p.base0D },
		DiagnosticUnderlineInfo = { undercurl = true, sp = p.base0D },
		DiagnosticUnderlineHint = { undercurl = true, sp = p.base0B },
		-- "Loud" tier: tinted bg makes errors/warnings pop in virtual-text.
		DiagnosticVirtualTextError = { fg = p.base08, bg = p.diag_bg_error },
		DiagnosticVirtualTextWarn = { fg = p.base0E, bg = p.diag_bg_warn },
		-- "Quiet" tier: fg only, no bg — informational without screaming.
		DiagnosticVirtualTextInfo = { fg = p.base0D },
		DiagnosticVirtualTextHint = { fg = p.base0B },
		DiagnosticSignError = { fg = p.base08 },
		DiagnosticSignWarn = { fg = p.base0E },
		DiagnosticSignInfo = { fg = p.base0D },
		DiagnosticSignHint = { fg = p.base0B },
		DiagnosticFloatingError = { fg = p.base08 },
		DiagnosticFloatingWarn = { fg = p.base0E },
		DiagnosticFloatingInfo = { fg = p.base0D },
		DiagnosticFloatingHint = { fg = p.base0B },
		-- Diagnostic tags (not severities — layered on top of the severity).
		-- Unnecessary: rust-analyzer / tsserver flag unused code with this; we
		-- want it visibly dimmed so the eye skips it. Deprecated: strikethrough
		-- on a muted fg so it reads as "don't use this anymore".
		DiagnosticUnnecessary = { fg = p.base03, italic = true },
		DiagnosticDeprecated = { fg = p.base03, strikethrough = true },

		LspReferenceText = { underline = true, sp = p.base04 },
		LspReferenceRead = { underline = true, sp = p.base04 },
		LspReferenceWrite = { underline = true, sp = p.base04 },
		LspDiagnosticsDefaultError = { link = "DiagnosticError" },
		LspDiagnosticsDefaultWarning = { link = "DiagnosticWarn" },
		LspDiagnosticsDefaultInformation = { link = "DiagnosticInfo" },
		LspDiagnosticsDefaultHint = { link = "DiagnosticHint" },
		LspDiagnosticsUnderlineError = { link = "DiagnosticUnderlineError" },
		LspDiagnosticsUnderlineWarning = { link = "DiagnosticUnderlineWarning" },
		LspDiagnosticsUnderlineInformation = { link = "DiagnosticUnderlineInformation" },
		LspDiagnosticsUnderlineHint = { link = "DiagnosticUnderlineHint" },
		LspInlayHint = { fg = p.base03, italic = true },

		-- Treesitter (legacy TS* groups) ----------------------------------------
		TSAnnotation = { fg = p.base0F },
		TSAttribute = { fg = p.base0A },
		TSBoolean = { fg = p.base09 },
		TSCharacter = { fg = p.base08 },
		TSComment = { fg = p.base03, italic = true },
		TSConstructor = { fg = p.base0D },
		TSConditional = { fg = p.base0E },
		TSConstant = { fg = p.base09 },
		TSConstBuiltin = { fg = p.base09, italic = true },
		TSConstMacro = { fg = p.base08 },
		TSError = { fg = p.base08 },
		TSException = { fg = p.base08 },
		TSField = { fg = p.base05 },
		TSFloat = { fg = p.base09 },
		TSFunction = { fg = p.base0D },
		TSFuncBuiltin = { fg = p.base0D, italic = true },
		TSFuncMacro = { fg = p.base08 },
		TSInclude = { fg = p.base0D },
		TSKeyword = { fg = p.base0E },
		TSKeywordFunction = { fg = p.base0E },
		TSKeywordOperator = { fg = p.base0E },
		TSLabel = { fg = p.base0A },
		TSMethod = { fg = p.base0D },
		TSNamespace = { fg = p.base08 },
		TSNone = { fg = p.base05 },
		TSNumber = { fg = p.base09 },
		TSOperator = { fg = p.base05 },
		TSParameter = { fg = p.base05 },
		TSParameterReference = { fg = p.base05 },
		TSProperty = { fg = p.base05 },
		TSPunctDelimiter = { fg = p.base0F },
		TSPunctBracket = { fg = p.base05 },
		TSPunctSpecial = { fg = p.base0F },
		TSRepeat = { fg = p.base0E },
		TSString = { fg = p.base0B },
		TSStringRegex = { fg = p.base0C },
		TSStringEscape = { fg = p.base0C },
		TSSymbol = { fg = p.base0B },
		TSTag = { fg = p.base08 },
		TSTagDelimiter = { fg = p.base0F },
		TSText = { fg = p.base05 },
		TSStrong = { bold = true },
		TSEmphasis = { fg = p.base09, italic = true },
		TSUnderline = { fg = p.base00, underline = true },
		TSStrike = { fg = p.base00, strikethrough = true },
		TSTitle = { fg = p.base0D },
		TSLiteral = { fg = p.base09 },
		TSURI = { fg = p.base09, underline = true },
		TSType = { fg = p.base0A },
		TSTypeBuiltin = { fg = p.base0A, italic = true },
		TSVariable = { fg = p.base08 },
		TSVariableBuiltin = { fg = p.base08, italic = true },
		TSDefinition = { underline = true, sp = p.base04 },
		TSDefinitionUsage = { underline = true, sp = p.base04 },
		TSCurrentScope = { bold = true },

		-- Treesitter (@-prefixed captures) --------------------------------------
		["@comment"] = { link = "TSComment" },
		["@error"] = { link = "TSError" },
		["@none"] = { link = "TSNone" },
		["@preproc"] = { link = "PreProc" },
		["@define"] = { link = "Define" },
		["@operator"] = { link = "TSOperator" },
		["@punctuation.delimiter"] = { link = "TSPunctDelimiter" },
		["@punctuation.bracket"] = { link = "TSPunctBracket" },
		["@punctuation.special"] = { link = "TSPunctSpecial" },
		["@string"] = { link = "TSString" },
		["@string.regex"] = { link = "TSStringRegex" },
		["@string.escape"] = { link = "TSStringEscape" },
		["@string.special"] = { link = "SpecialChar" },
		["@character"] = { link = "TSCharacter" },
		["@character.special"] = { link = "SpecialChar" },
		["@boolean"] = { link = "TSBoolean" },
		["@number"] = { link = "TSNumber" },
		["@float"] = { link = "TSFloat" },
		["@function"] = { link = "TSFunction" },
		["@function.call"] = { link = "TSFunction" },
		["@function.builtin"] = { link = "TSFuncBuiltin" },
		["@function.macro"] = { link = "TSFuncMacro" },
		["@method"] = { link = "TSMethod" },
		["@method.call"] = { link = "TSMethod" },
		["@constructor"] = { link = "TSConstructor" },
		["@parameter"] = { link = "TSParameter" },
		["@keyword"] = { link = "TSKeyword" },
		["@keyword.function"] = { link = "TSKeywordFunction" },
		["@keyword.operator"] = { link = "TSKeywordOperator" },
		["@keyword.return"] = { link = "TSKeyword" },
		["@conditional"] = { link = "TSConditional" },
		["@repeat"] = { link = "TSRepeat" },
		["@debug"] = { link = "Debug" },
		["@label"] = { link = "TSLabel" },
		["@include"] = { link = "TSInclude" },
		["@exception"] = { link = "TSException" },
		["@type"] = { link = "TSType" },
		["@type.builtin"] = { link = "TSTypeBuiltin" },
		["@type.qualifier"] = { link = "TSKeyword" },
		["@type.definition"] = { link = "TSType" },
		["@storageclass"] = { link = "StorageClass" },
		["@attribute"] = { link = "TSAttribute" },
		["@field"] = { link = "TSField" },
		["@property"] = { link = "TSProperty" },
		["@variable"] = { link = "TSVariable" },
		["@variable.builtin"] = { link = "TSVariableBuiltin" },
		["@constant"] = { link = "TSConstant" },
		["@constant.builtin"] = { link = "TSConstant" },
		["@constant.macro"] = { link = "TSConstant" },
		["@namespace"] = { link = "TSNamespace" },
		["@symbol"] = { link = "TSSymbol" },
		["@text"] = { link = "TSText" },
		["@text.diff.add"] = { link = "DiffAdd" },
		["@text.diff.delete"] = { link = "DiffDelete" },
		["@text.strong"] = { link = "TSStrong" },
		["@text.emphasis"] = { link = "TSEmphasis" },
		["@text.underline"] = { link = "TSUnderline" },
		["@text.strike"] = { link = "TSStrike" },
		["@text.title"] = { link = "TSTitle" },
		["@text.literal"] = { link = "TSLiteral" },
		["@text.uri"] = { link = "TSUri" },
		["@text.math"] = { link = "Number" },
		["@text.environment"] = { link = "Macro" },
		["@text.environment.name"] = { link = "Type" },
		["@text.reference"] = { link = "TSParameterReference" },
		["@text.todo"] = { link = "Todo" },
		["@text.note"] = { link = "Tag" },
		["@text.warning"] = { link = "DiagnosticWarn" },
		["@text.danger"] = { link = "DiagnosticError" },
		["@tag"] = { link = "TSTag" },
		["@tag.attribute"] = { link = "TSAttribute" },
		["@tag.delimiter"] = { link = "TSTagDelimiter" },
		["@function.method"] = { link = "@method" },
		["@function.method.call"] = { link = "@method.call" },
		["@comment.error"] = { link = "@text.danger" },
		["@comment.warning"] = { link = "@text.warning" },
		["@comment.hint"] = { link = "DiagnosticHint" },
		["@comment.info"] = { link = "DiagnosticInfo" },
		["@comment.todo"] = { link = "@text.todo" },
		["@diff.plus"] = { link = "@text.diff.add" },
		["@diff.minus"] = { link = "@text.diff.delete" },
		["@diff.delta"] = { link = "DiffChange" },
		["@string.special.url"] = { link = "@text.uri" },
		["@keyword.directive"] = { link = "@preproc" },
		["@keyword.directive.define"] = { link = "@define" },
		["@keyword.storage"] = { link = "@storageclass" },
		["@keyword.conditional"] = { link = "@conditional" },
		["@keyword.debug"] = { link = "@debug" },
		["@keyword.exception"] = { link = "@exception" },
		["@keyword.import"] = { link = "@include" },
		["@keyword.repeat"] = { link = "@repeat" },
		["@variable.parameter"] = { link = "@parameter" },
		["@variable.member"] = { link = "@field" },
		["@module"] = { link = "@namespace" },
		["@number.float"] = { link = "@float" },
		["@string.special.symbol"] = { link = "@symbol" },
		["@string.regexp"] = { link = "@string.regex" },
		["@markup.strong"] = { link = "@text.strong" },
		["@markup.italic"] = { link = "Italic" },
		["@markup.strikethrough"] = { link = "@text.strike" },
		["@markup.heading"] = { link = "@text.title" },
		["@markup.raw"] = { link = "@text.literal" },
		["@markup.link"] = { link = "@text.reference" },
		["@markup.link.url"] = { link = "@text.uri" },
		["@markup.link.label"] = { link = "@string.special" },
		["@markup.list"] = { link = "@punctuation.special" },

		-- nvim-ts-rainbow -------------------------------------------------------
		rainbowcol1 = { fg = p.base06 },
		rainbowcol2 = { fg = p.base09 },
		rainbowcol3 = { fg = p.base0A },
		rainbowcol4 = { fg = p.base07 },
		rainbowcol5 = { fg = p.base0C },
		rainbowcol6 = { fg = p.base0D },
		rainbowcol7 = { fg = p.base0E },

		-- Floats / terminal / misc ----------------------------------------------
		NvimInternalError = { fg = p.base00, bg = p.base08 },
		NormalFloat = { fg = p.base05, bg = p.base00 },
		FloatBorder = { fg = p.base05, bg = p.base00 },
		NormalNC = { fg = p.base05, bg = p.base00 },
		TermCursor = { fg = p.base00, bg = p.base05 },
		TermCursorNC = { fg = p.base00, bg = p.base05 },
		User1 = { fg = p.base08, bg = p.base02 },
		User2 = { fg = p.base0E, bg = p.base02 },
		User3 = { fg = p.base05, bg = p.base02 },
		User4 = { fg = p.base0C, bg = p.base02 },
		User5 = { fg = p.base05, bg = p.base02 },
		User6 = { fg = p.base05, bg = p.base01 },
		User7 = { fg = p.base05, bg = p.base02 },
		User8 = { fg = p.base00, bg = p.base02 },
		User9 = { fg = p.base00, bg = p.base02 },
		-- TreesitterContext: sticky context header at top of viewport. Bg
		-- matches the lualine main bar (bg_code) so it reads as "UI chrome,
		-- not real code". A subtle bottom underline separates context from
		-- the live buffer.
		TreesitterContext = { bg = p.bg_code, italic = true },
		TreesitterContextLineNumber = { fg = p.base04, bg = p.bg_code },
		TreesitterContextBottom = { underline = true, sp = p.base03 },
		TreesitterContextSeparator = { fg = p.base03, bg = p.bg_code },

		-- Telescope: transparent main bg (terminal shows through), title chips
		-- and selection still use accent colors so they pop against the void.
		TelescopeNormal = { bg = p.base00, fg = p.base05 },
		TelescopeBorder = { fg = p.base03, bg = p.base00 }, -- subtle mauve border
		TelescopePromptNormal = { fg = p.base05, bg = p.base00 },
		TelescopePromptBorder = { fg = p.base03, bg = p.base00 },
		TelescopePromptPrefix = { fg = p.base0D, bg = p.base00 }, -- violet `>` prompt
		-- Title chips: one per pane, each a different theme accent
		TelescopePromptTitle = { fg = p.bg_code, bg = p.base0D, bold = true }, -- violet
		TelescopeResultsTitle = { fg = p.bg_code, bg = p.base0E, bold = true }, -- pink
		TelescopePreviewTitle = { fg = p.bg_code, bg = p.base0B, bold = true }, -- green
		-- Selection matches cmp's PmenuSel pattern: statusline_b bg + bold
		TelescopeSelection = { bg = p.statusline_b, bold = true },
		TelescopePreviewLine = { bg = p.statusline_b },
		-- Match characters in results (the typed letters that matched)
		TelescopeMatching = { fg = p.base08, bold = true }, -- amber (matches cmp's match chars)

		-- nvim-notify -----------------------------------------------------------
		NotifyERRORBorder = { fg = p.base08 },
		NotifyWARNBorder = { fg = p.base0E },
		NotifyINFOBorder = { fg = p.base05 },
		NotifyDEBUGBorder = { fg = p.base0C },
		NotifyTRACEBorder = { fg = p.base0C },
		NotifyERRORIcon = { fg = p.base08 },
		NotifyWARNIcon = { fg = p.base0E },
		NotifyINFOIcon = { fg = p.base05 },
		NotifyDEBUGIcon = { fg = p.base0C },
		NotifyTRACEIcon = { fg = p.base0C },
		NotifyERRORTitle = { fg = p.base08 },
		NotifyWARNTitle = { fg = p.base0E },
		NotifyINFOTitle = { fg = p.base05 },
		NotifyDEBUGTitle = { fg = p.base0C },
		NotifyTRACETitle = { fg = p.base0C },
		NotifyERRORBody = { link = "Normal" },
		NotifyWARNBody = { link = "Normal" },
		NotifyINFOBody = { link = "Normal" },
		NotifyDEBUGBody = { link = "Normal" },
		NotifyTRACEBody = { link = "Normal" },

		-- indent-blankline ------------------------------------------------------
		IndentBlanklineChar = { fg = p.base02, nocombine = true },
		IndentBlanklineContextChar = { fg = p.base04, nocombine = true },
		IblIndent = { fg = p.base02, nocombine = true },
		IblWhitespace = { link = "Whitespace" },
		IblScope = { fg = p.base04, nocombine = true },

		-- nvim-cmp (base layer; richer kind colors set in overrides) ------------
		CmpDocumentationBorder = { fg = p.base05, bg = p.base00 },
		CmpDocumentation = { fg = p.base05, bg = p.base00 },
		CmpItemAbbr = { fg = p.base05, bg = p.base01 },
		CmpItemAbbrDeprecated = { fg = p.base03, strikethrough = true },
		CmpItemAbbrMatch = { fg = p.base0D },
		CmpItemAbbrMatchFuzzy = { fg = p.base0D },
		CmpItemKindDefault = { fg = p.base05 },
		CmpItemMenu = { fg = p.base04 },
		CmpItemKindKeyword = { fg = p.base0E },
		CmpItemKindVariable = { fg = p.base08 },
		CmpItemKindConstant = { fg = p.base09 },
		CmpItemKindReference = { fg = p.base08 },
		CmpItemKindValue = { fg = p.base09 },
		CmpItemKindFunction = { fg = p.base0D },
		CmpItemKindMethod = { fg = p.base0D },
		CmpItemKindConstructor = { fg = p.base0D },
		CmpItemKindClass = { fg = p.base0A },
		CmpItemKindInterface = { fg = p.base0A },
		CmpItemKindStruct = { fg = p.base0A },
		CmpItemKindEvent = { fg = p.base0A },
		CmpItemKindEnum = { fg = p.base0A },
		CmpItemKindUnit = { fg = p.base0A },
		CmpItemKindModule = { fg = p.base05 },
		CmpItemKindProperty = { fg = p.base08 },
		CmpItemKindField = { fg = p.base08 },
		CmpItemKindTypeParameter = { fg = p.base0A },
		CmpItemKindEnumMember = { fg = p.base0A },
		CmpItemKindOperator = { fg = p.base05 },
		CmpItemKindSnippet = { fg = p.base04 },

		-- vim-illuminate --------------------------------------------------------
		IlluminatedWordText = { underline = true, sp = p.base04 },
		IlluminatedWordRead = { underline = true, sp = p.base04 },
		IlluminatedWordWrite = { underline = true, sp = p.base04 },

		-- LSP semantic tokens ---------------------------------------------------
		["@class"] = { link = "TSType" },
		["@struct"] = { link = "TSType" },
		["@enum"] = { link = "TSType" },
		["@enumMember"] = { link = "Constant" },
		["@event"] = { link = "Identifier" },
		["@interface"] = { link = "Structure" },
		["@modifier"] = { link = "Identifier" },
		["@regexp"] = { link = "TSStringRegex" },
		["@typeParameter"] = { link = "Type" },
		["@decorator"] = { link = "Identifier" },
		["@lsp.type.namespace"] = { link = "@namespace" },
		["@lsp.type.type"] = { link = "@type" },
		["@lsp.type.class"] = { link = "@type" },
		["@lsp.type.enum"] = { link = "@type" },
		["@lsp.type.interface"] = { link = "@type" },
		["@lsp.type.struct"] = { link = "@type" },
		["@lsp.type.parameter"] = { link = "@parameter" },
		["@lsp.type.variable"] = { link = "@variable" },
		["@lsp.type.property"] = { link = "@property" },
		["@lsp.type.enumMember"] = { link = "@constant" },
		["@lsp.type.function"] = { link = "@function" },
		["@lsp.type.method"] = { link = "@method" },
		["@lsp.type.macro"] = { link = "@function.macro" },
		["@lsp.type.decorator"] = { link = "@function" },

		-- mini.completion -------------------------------------------------------
		MiniCompletionActiveParameter = { link = "CursorLine" },

		-- nvim-dap-ui -----------------------------------------------------------
		DapUINormal = { link = "Normal" },
		DapUIVariable = { link = "Normal" },
		DapUIScope = { fg = p.base0D },
		DapUIType = { fg = p.base0E },
		DapUIValue = { link = "Normal" },
		DapUIModifiedValue = { fg = p.base0D, bold = true },
		DapUIDecoration = { fg = p.base0D },
		DapUIThread = { fg = p.base0B },
		DapUIStoppedThread = { fg = p.base0D },
		DapUIFrameName = { link = "Normal" },
		DapUISource = { fg = p.base0E },
		DapUILineNumber = { fg = p.base0D },
		DapUIFloatNormal = { link = "NormalFloat" },
		DapUIFloatBorder = { fg = p.base0D },
		DapUIWatchesEmpty = { fg = p.base08 },
		DapUIWatchesValue = { fg = p.base0B },
		DapUIWatchesError = { fg = p.base08 },
		DapUIBreakpointsPath = { fg = p.base0D },
		DapUIBreakpointsInfo = { fg = p.base0B },
		DapUIBreakpointsCurrentLine = { fg = p.base0B, bold = true },
		DapUIBreakpointsLine = { link = "DapUILineNumber" },
		DapUIBreakpointsDisabledLine = { fg = p.base02 },
		DapUICurrentFrameName = { link = "DapUIBreakpointsCurrentLine" },
		DapUIStepOver = { fg = p.base0D },
		DapUIStepInto = { fg = p.base0D },
		DapUIStepBack = { fg = p.base0D },
		DapUIStepOut = { fg = p.base0D },
		DapUIStop = { fg = p.base08 },
		DapUIPlayPause = { fg = p.base0B },
		DapUIRestart = { fg = p.base0B },
		DapUIUnavailable = { fg = p.base02 },
		DapUIWinSelect = { fg = p.base0D, bold = true },
		DapUIEndofBuffer = { link = "EndOfBuffer" },
		DapUINormalNC = { link = "Normal" },
		DapUIPlayPauseNC = { fg = p.base0B },
		DapUIRestartNC = { fg = p.base0B },
		DapUIStopNC = { fg = p.base08 },
		DapUIUnavailableNC = { fg = p.base02 },
		DapUIStepOverNC = { fg = p.base0D },
		DapUIStepIntoNC = { fg = p.base0D },
		DapUIStepBackNC = { fg = p.base0D },
		DapUIStepOutNC = { fg = p.base0D },
	}

	-- Per-plugin tuning. Applied after the base layer; each entry fully
	-- replaces the corresponding group (matching nvim_set_hl semantics).
	-- Note: highlight group names are case-insensitive, so the lowercase
	-- diff* groups intentionally collapse onto the base16 Diff* groups.
	local overrides = {
		-- highlight.nix
		ColorColumn = { bg = p.bg_code },
		DiffChange = { fg = p.base08 },
		DiffDelete = { fg = p.red },
		FloatBorder = { fg = p.border },
		-- Pmenu container matches the lualine main bar (bg_code); selected row
		-- matches the lualine branch section (statusline_b deep wine). Same
		-- source colors → renders identically next to lualine.
		Pmenu = { bg = p.bg_code, fg = p.menu_fg },
		PmenuSel = { bg = p.statusline_b, bold = true },
		TabLineFill = { bg = p.base00 },
		TermCursor = { underdotted = true, sp = p.base08 },
		GitSignsAddInline = { underdotted = true, sp = p.base06 },
		GitSignsDeleteInline = { underdotted = true, sp = p.red, fg = p.delete_fg },
		TSLiteral = { bg = p.bg_code, fg = p.base09 },
		TSNumber = { fg = p.base0A },
		TSProperty = { fg = p.base0C },
		TSType = { fg = p.base09 },
		DiagnosticQuoted = { fg = p.diag_quote },
		diffAdded = { fg = p.base0B },
		diffChanged = { fg = p.base0C },
		diffRemoved = { fg = p.base0E },
		diffFile = { fg = p.base0D },

		-- nvim-cmp kind chips (cmp.nix)
		-- Item names: no bg (let Pmenu's bg_code show through). Match chars:
		-- violet (base0D) — the theme's primary accent. Kind labels: fg-only,
		-- so they read as colored text on Pmenu rather than chips. Each kind
		-- group maps onto one of xdusk's eight base accents so the palette
		-- stays self-consistent.
		CmpItemAbbr = { fg = p.base05 },
		CmpItemAbbrDeprecated = { fg = p.base03, strikethrough = true },
		CmpItemAbbrMatch = { fg = p.base08, bold = true },
		CmpItemAbbrMatchFuzzy = { fg = p.base08, bold = true },
		CmpItemMenu = { fg = p.base03, italic = true },
		CmpItemKindField = { fg = p.base0E }, -- pink
		CmpItemKindProperty = { fg = p.base0E },
		CmpItemKindEvent = { fg = p.base0E },
		CmpItemKindText = { fg = p.base0B }, -- green
		CmpItemKindEnum = { fg = p.base0B },
		CmpItemKindKeyword = { fg = p.base0B },
		CmpItemKindConstant = { fg = p.base09 }, -- cyan-blue
		CmpItemKindConstructor = { fg = p.base09 },
		CmpItemKindReference = { fg = p.base09 },
		CmpItemKindFunction = { fg = p.base0D }, -- violet
		CmpItemKindStruct = { fg = p.base0D },
		CmpItemKindClass = { fg = p.base0D },
		CmpItemKindModule = { fg = p.base0D },
		CmpItemKindOperator = { fg = p.base0D },
		CmpItemKindVariable = { fg = p.base08 }, -- amber
		CmpItemKindFile = { fg = p.base08 },
		CmpItemKindUnit = { fg = p.base0C }, -- yellow
		CmpItemKindSnippet = { fg = p.base0E }, -- pink
		CmpItemKindFolder = { fg = p.base0C },
		CmpItemKindMethod = { fg = p.base0A }, -- burnt orange
		CmpItemKindValue = { fg = p.base0A },
		CmpItemKindEnumMember = { fg = p.base0A },
		CmpItemKindInterface = { fg = p.base0F }, -- coral
		CmpItemKindColor = { fg = p.base0F },
		CmpItemKindTypeParameter = { fg = p.base0F },

		-- cursortab.nvim — single-line LLM suggestions arrive as
		-- "modification" groups (the model is asked to replace the line, not
		-- append to it), which renders as an overlay window with
		-- `winhighlight = "Normal:CursorTabModification"`. So this group IS
		-- the ghost-text styling, not CursorTabCompletion. Mauve italic, no
		-- bg → reads as a hint.
		CursorTabCompletion = { bg = p.ghost_text_bg, fg = p.base03, italic = true },
		CursorTabModification = { bg = p.ghost_text_bg, fg = p.base03, italic = true },
		CursorTabDeletion = { bg = p.deletion_bg },

		-- render-markdown.nix
		RenderMarkdownBullet = { fg = p.bullet },
		RenderMarkdownCode = { bg = p.bg_code },
		RenderMarkdownH1Bg = { bg = p.bg_header, fg = p.base0D },
		RenderMarkdownH2Bg = { bg = p.bg_header, fg = p.base0D },
		RenderMarkdownH3Bg = { bg = p.bg_header, fg = p.base0D },
		RenderMarkdownH4Bg = { bg = p.bg_header, fg = p.base0D },
		RenderMarkdownH5Bg = { bg = p.bg_header, fg = p.base0D },
		RenderMarkdownH6Bg = { bg = p.bg_header, fg = p.base0D },

		-- markview.nix
		MarkviewListItemMinus = { fg = p.bullet },
		MarkviewListItemPlus = { fg = p.bullet },
		MarkviewListItemStar = { fg = p.bullet },
		MarkviewCode = { bg = p.bg_code },
		MarkviewHeading1 = { bg = p.bg_header, fg = p.base0D },
		MarkviewHeading2 = { bg = p.bg_header, fg = p.base0D },
		MarkviewHeading3 = { bg = p.bg_header, fg = p.base0D },
		MarkviewHeading4 = { bg = p.bg_header, fg = p.base0D },
		MarkviewHeading5 = { bg = p.bg_header, fg = p.base0D },
		MarkviewHeading6 = { bg = p.bg_header, fg = p.base0D },

		-- nvim-scrollview.nix
		ScrollView = { bg = p.white },

		-- blink.pairs rainbow brackets + unmatched-pair marker
		RainbowDelimiterRed = { fg = p.base0F }, -- coral
		RainbowDelimiterYellow = { fg = p.base0C }, -- yellow
		RainbowDelimiterBlue = { fg = p.base09 }, -- cyan-blue
		RainbowDelimiterOrange = { fg = p.base08 }, -- amber
		RainbowDelimiterGreen = { fg = p.base0B }, -- green
		RainbowDelimiterViolet = { fg = p.base0D }, -- violet
		BlinkPairsUnmatched = { fg = p.red, bold = true },

		-- neogit.nix — Neogit's defaults use bright bg2/line_green/line_red
		-- panels which clash with the rest of the (mostly transparent) UI.
		-- Context rows link to Normal: inherits the transparent base bg,
		-- and crucially leaves a non-empty hl table so Neogit's setup_highlights
		-- (which falls back to its bg1 grey when `is_set` reports false) sees
		-- our override as already-set.
		NeogitDiffContext = { link = "Normal" },
		NeogitDiffContextHighlight = { link = "Normal" },
		NeogitDiffContextCursor = { link = "Normal" },
		-- Neogit's status buffer inherits CursorLine (= base01 #603090).
		-- That reads as a flat dark plum on top of the transparent base and
		-- doesn't pop. Brighter, more saturated violet for the active row.
		NeogitCursorLine = { bg = "#7e3aba" },
		-- Darker tinted bg than Neogit's defaults so add/delete rows don't
		-- compete with code colors. fg stays green/red on all variants —
		-- only NeogitHunkHeader*Highlight/Cursor switches to golden for the
		-- "this hunk is active" cue.
		NeogitDiffAdd = { bg = "#0e2810", fg = p.base0B },
		NeogitDiffAddHighlight = { bg = "#0e2810", fg = p.base0B, bold = true },
		NeogitDiffAddCursor = { bg = "#0e2810", fg = p.base0B, bold = true },
		NeogitDiffAdditions = { fg = p.base0B },
		NeogitDiffDelete = { bg = "#3a1212", fg = p.delete_fg },
		NeogitDiffDeleteHighlight = { bg = "#3a1212", fg = p.delete_fg, bold = true },
		NeogitDiffDeleteCursor = { bg = "#3a1212", fg = p.delete_fg, bold = true },
		NeogitDiffDeletions = { fg = p.delete_fg },
		-- Word-diff (intra-line changed words). Underline + colored squiggle
		-- color (sp) instead of bold + colored fg, so the changed token reads
		-- as an annotation over the line's existing diff color rather than
		-- replacing it.
		NeogitDiffAddInline = { underline = true, sp = p.base0B },
		NeogitDiffDeleteInline = { underline = true, sp = p.delete_fg },
		NeogitHunkHeader = { bg = p.bg_header, fg = p.base0D, bold = true },
		NeogitHunkHeaderHighlight = { bg = p.statusline_b, fg = p.base0C, bold = true },
		NeogitHunkHeaderCursor = { bg = p.statusline_b, fg = p.base0C, bold = true },
		NeogitDiffHeader = { bg = p.bg_header, fg = p.base0D, bold = true },
		NeogitDiffHeaderHighlight = { bg = p.bg_header, fg = p.base0D, bold = true },
	}

	-- Apply a group, deriving ctermfg/ctermbg from its gui colors so the theme
	-- also works in 256-color terminals. Style flags (bold/italic/undercurl/...)
	-- are mirrored to cterm by nvim_set_hl automatically.
	local cterm = p.cterm
	local function apply(group, spec)
		if spec.fg and cterm[spec.fg] ~= nil then
			spec.ctermfg = cterm[spec.fg]
		end
		if spec.bg and cterm[spec.bg] ~= nil then
			spec.ctermbg = cterm[spec.bg]
		end
		vim.api.nvim_set_hl(0, group, spec)
	end

	for group, spec in pairs(groups) do
		apply(group, spec)
	end
	for group, spec in pairs(overrides) do
		apply(group, spec)
	end

	-- Terminal palette (matches the base16 ANSI mapping).
	local term = {
		p.base00,
		p.base08,
		p.base0B,
		p.base0A,
		p.base0D,
		p.base0E,
		p.base0C,
		p.base05,
		p.base03,
		p.base08,
		p.base0B,
		p.base0A,
		p.base0D,
		p.base0E,
		p.base0C,
		p.base07,
	}
	for i = 0, 15 do
		vim.g["terminal_color_" .. i] = term[i + 1]
	end
end

return M
