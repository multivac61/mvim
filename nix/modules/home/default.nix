{ flake, ... }:
{
  config,
  pkgs,
  perSystem,
  ...
}:
let
  nvim-lsp-packages = flake.lib.nvim-lsp-packages { inherit pkgs; };
  treesitter-grammars = flake.lib.treesitter-grammars { inherit pkgs; };
  mvim = perSystem.self.mvim;
in
{
  home.packages = nvim-lsp-packages ++ [ mvim ];
  home.activation.nvim = ''
    echo "${treesitter-grammars.rev}" > "${config.xdg.configHome}/nvim/treesitter-rev"
    XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
    NVIM_APPNAME=''${NVIM_APPNAME:-nvim}
    if [[ -f $XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json ]]; then
      if ! grep -q "${treesitter-grammars.rev}" "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"; then
        ${mvim}/bin/nvim --headless "+Lazy! update" +qa
      fi
    fi
  '';
  xdg.dataFile."nvim/site/parser".source = treesitter-grammars;
}
