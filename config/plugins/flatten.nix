{ pkgs, ... }:
{
  # Forward nested `nvim` calls from any child terminal into this parent
  # instance — open the file as a buffer here instead of spawning a nested
  # Neovim. Works because $NVIM is inherited into toggleterm's shell, and
  # the child detects it and RPC-forwards.
  # https://github.com/willothy/flatten.nvim/
  # Not a first-party nixvim module — pulled from nixpkgs and set up directly.
  config = {
    extraPlugins = [ pkgs.vimPlugins.flatten-nvim ];

    # Must load before any child nvim is spawned, so set up eagerly. The
    # setup call registers an RPC handler that the child uses to forward.
    extraConfigLua = # lua
      ''
        require("flatten").setup({
          window = {
            -- Open the incoming buffer in the last-used non-terminal window
            -- (the main editor area) instead of replacing the terminal.
            open = "alternate",
          },
          -- Block the child until the buffer is closed for tools that
          -- expect an editor to run synchronously (git commit, jj describe,
          -- `EDITOR=nvim foo`). For plain `nvim file.txt`, return immediately.
          block_for = {
            gitcommit = true,
            gitrebase = true,
          },
          -- `nvim` with no args inside the terminal still nests — opening
          -- an empty editor inside the parent would be confusing.
          nest_if_no_args = true,
        })
      '';
  };
}
