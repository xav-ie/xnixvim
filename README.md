# xnixvim

My nixvim (nixified neovim) config!

https://github.com/user-attachments/assets/d5d9ac79-b8a7-4f26-81d4-33ad33353205

Nixvim is an amazing project that brings nix to neovim. It makes running neovim
with your complete config on alien systems easy, consistent, and fast! You can
find out more on the [nixvim repository](https://github.com/nix-community/nixvim).

Try this command to run _my_ neovim configuration:

```sh
nix run github:xav-ie/xnixvim
```

Basically, if you have `nix` installed, you can run this configuation!

You might also enjoy [my dotfiles](https://github.com/xav-ie/dots)!

## TODO

- [x] CI
- [x] Fast CI
- [x] Screenshot
  - [ ] with CI
- [ ] separate theme out and share
- [x] local completions
- [ ] snippets
- [ ] better large file support
- [ ] proper spelling and dictionary support to add new words
- [ ] org concealment
- [ ] checkout ts-auto-tag:
  - [pta2002/nixos-config/modules/nvim.nix](https://github.com/pta2002/nixos-config/blob/main/modules/nvim.nix)
- [ ] checkout these other plugins:
  - [Alexnortung/nollevim/config/appearance/treesitter.nix#L2](https://github.com/Alexnortung/nollevim/blob/fcc35456c567c6108774e839d617c97832217e67/config/appearance/treesitter.nix#L2)
- [ ] LSP code actions with telescope?
  - [nvim-telescope/telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim)
  - [traxys/nvim-flake/config.nix#L306](https://github.com/traxys/nvim-flake/blob/c753bb1e624406ef454df9e8cb59d0996000dc93/config.nix#L306)
- [ ] read through these config(s) fully:
  - [Builditluc/dotfiles/dotnix/hm/nvim.nix#L95](https://github.com/Builditluc/dotfiles/blob/0989f7bf0d147232b4133d9fe4fb166465e93b94/dotnix/hm/nvim.nix#L95)
  - [pta2002/nixos-config/modules/nvim.nix](https://github.com/pta2002/nixos-config/blob/main/modules/nvim.nix)
  - [evccyr/dotfiles/nix/neovim/default.nix](https://github.com/evccyr/dotfiles/blob/main/nix/neovim/default.nix)
  - [prescientmoon/everything-nix/home/features/neovim/default.nix](https://github.com/prescientmoon/everything-nix/blob/82fca70a6e882365a76e947cc0e01db07d6cc13c/home/features/neovim/default.nix)
  - [NickHu/nixvim-flake/config/default.nix](https://github.com/NickHu/nixvim-flake/blob/1f47b9cfb5d8e86a48cf8d64bfb3fd0389d14f75/config/default.nix)
  - [SchnozzleCat/Nix/home/neovim.nix](https://github.com/SchnozzleCat/Nix/blob/160e617a28ef25be2311445fc407ca54e53437a7/home/neovim.nix)
- [ ] write my own or find someone else's snippets for ts. specifically all the
      map, reduce, forEach should have snippets
  - [https://www.youtube.com/watch?v=Dn800rlPIho](https://www.youtube.com/watch?v=Dn800rlPIho)
  - [L3MON4D3/LuaSnip#resources-for-new-users](https://github.com/L3MON4D3/LuaSnip#resources-for-new-users)
  - [https://www.youtube.com/watch?v=FmHhonPjvvA](https://www.youtube.com/watch?v=FmHhonPjvvA)
- [ ] harpoon?
- [ ] Find better manager
  - [mhinz/vim-startify](https://github.com/mhinz/vim-startify)
  - [tpope/vim-obsession](https://github.com/tpope/vim-obsession)
