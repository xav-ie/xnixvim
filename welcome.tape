Require nvim

# TODO: make hermetic
Set FontFamily "Maple Mono NF"
Set FontSize 24
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
Escape Sleep 500ms
Type "OHello, welcome to my Neovim configuration!" Sleep 500ms Enter
Sleep 1s
Type "The main configuration starts in `flake.nix`, which just imports `config/default.nix`" Sleep 500ms
Escape Sleep 500ms
Sleep 3s
Type "h" Sleep 500ms Type "gf" Sleep 500ms
Type "O# This file is `config/default.nix`" Sleep 500ms
Escape Sleep 500ms
Type "/imports" Sleep 500ms Enter Sleep 500ms
Escape Sleep 500ms
Type "O# The most interesting import here is `./plugins` which is at `config/plugins/default.nix`" Sleep 500ms
Escape Sleep 500ms
Sleep 4s
Type "h" Sleep 500ms Type "gf" Sleep 500ms
Type "O# This file, `config/plugins/default.nix`, has 99% of the plugin configuration." Sleep 500ms
Enter Sleep 500ms
Type "# Feel free to explore and pillage!" Sleep 500ms
Escape Sleep 500ms
Sleep 12s
Hide
Type ":qa!"
Enter Sleep 500ms
