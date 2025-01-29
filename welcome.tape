Require nvim

# TODO: make hermetic
Set FontFamily "Maple Mono NF"
Set FontSize 32
Set Width 1920
Set Height 1080
Set Padding 0
Set PlaybackSpeed 0.5
Set Theme "Builtin Dark"

Type "nvim README.md" Sleep 500ms Enter
# The autocompletions at this speed are distracting
Hide
Type ':lua require("cmp").setup({enabled = false})' Sleep 500ms
Enter Sleep 500ms
Show

Sleep 2s
Type "O" Sleep 500ms
Hide Escape Sleep 500ms Type "O" Sleep 500ms Show
Type "Hello, " Sleep 500ms
Type "welcome to my Neovim configuration!" Sleep 500ms Enter
Sleep 2s
Type "The main configuration starts in `flake.nix`, " Sleep 250ms
Type "which just imports" Enter
Type "`config/default.nix`." Sleep 500ms
Escape Sleep 500ms
Sleep 4s
Type "hh" Sleep 500ms
Hide Type "gf" Sleep 500ms Show
Type "O# This file is `config/default.nix`." Sleep 500ms
Escape Sleep 500ms
Sleep 2s
Type "/imports" Sleep 500ms
Hide Enter Sleep 500ms Escape Sleep 500ms Type "O# " Sleep 500ms Show
Type "The most interesting import here is `./plugins`" Sleep 1s
Type ", which is at"
Enter Type "# `config/plugins/default.nix`" Sleep 500ms
Escape Sleep 500ms
Sleep 4s
Type "h" Sleep 500ms
Hide Type "gf" Sleep 500ms Show
Type "O# This file, " Sleep 250ms
Type "`config/plugins/default.nix`," Sleep 500ms
Type " has 99% of the plugin configuration." Sleep 500ms
Enter Sleep 500ms
Type "# Feel free to explore and pillage!" Sleep 500ms
Escape Sleep 500ms
Sleep 12s

Hide
Type ":qa!"
Enter Sleep 500ms
