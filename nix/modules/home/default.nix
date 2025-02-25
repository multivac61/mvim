{ flake, ... }:
{
  pkgs,
  ...
}:
let
  nvim-lsp-packages = flake.lib.nvim-lsp-packages { inherit pkgs; };
  treesitter-grammars = flake.lib.treesitter-grammars { inherit pkgs; };
  neovim = flake.lib.neovim { inherit pkgs; };
in
{
  home.packages = nvim-lsp-packages ++ [ neovim ];

  home.activation.nvim = ''
    XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
    NVIM_APPNAME=''${NVIM_APPNAME:-nvim}
    mkdir -p $XDG_CONFIG_HOME/$NVIM_APPNAME
    echo "${treesitter-grammars.rev}" > "$XDG_CONFIG_HOME/nvim/treesitter-rev"
    if [[ -f $XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json ]]; then
      if ! grep -q "${treesitter-grammars.rev}" "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"; then
        ${neovim}/bin/nvim --headless "+Lazy! update" +qa
      fi
    fi
  '';

  xdg.dataFile."nvim".source = "${flake}";
  xdg.dataFile."nvim".recursive = true;
  xdg.dataFile."nvim/site/parser".source = treesitter-grammars;
}
