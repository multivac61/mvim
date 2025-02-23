{
  pkgs,
}:
with pkgs;
let
  nvim-lsp-packages = [
    nodejs # copilot
    terraform-ls
    pyright

    # based on ./suggested-pkgs.json
    gopls
    golangci-lint
    nodePackages.bash-language-server
    taplo-lsp
    marksman
    selene
    rust-analyzer
    yaml-language-server
    nil
    nixd
    shellcheck
    shfmt
    ruff
    typos-lsp
    typos
    nixfmt-rfc-style
    terraform-ls
    clang-tools
    nodePackages.prettier
    stylua

    # based on https://github.com/ray-x/go.nvim#go-binaries-install-and-update
    go
    delve
    ginkgo
    gofumpt
    golines
    gomodifytags
    gotests
    gotestsum
    gotools
    govulncheck
    iferr
    impl
    zls

    # mvim custom
    stdenv.cc # needed to compile and link nl and other packages
    elixir-ls
    emmet-language-server
    vscode-langservers-extracted # json-lsp
    lua-language-server
    sqlfluff
    svelte-language-server
    tailwindcss-language-server
    taplo
    vtsls
    xsel # for lazygit copy/paste to clipboard
    ripgrep
    ast-grep
    fd
    fzf
    cargo
    python3 # sqlfluff
    unzip
    bash-language-server
    lazygit
    coreutils # Explicitly include coreutils

    #ocaml-ng.ocamlPackages_5_0.ocaml-lsp
    #ocaml-ng.ocamlPackages_5_0.ocamlformat
    # does not build yet on aarch64
  ] ++ lib.optional (stdenv.hostPlatform.system == "x86_64-linux") deno;
  # ++ lib.optional (!stdenv.hostPlatform.isDarwin) sumneko-lua-language-server;
  neovim = wrapNeovimUnstable neovim-unwrapped (
    neovimUtils.makeNeovimConfig {
      wrapRc = false;
      withRuby = false;
      # extraLuaPackages = ps: [ (ps.callPackage ./lua-tiktoken.nix { }) ];
    }
  );
  treesitter-grammars =
    let
      grammars = lib.filterAttrs (
        n: _: lib.hasPrefix "tree-sitter-" n
      ) vimPlugins.nvim-treesitter.builtGrammars;
      symlinks = lib.mapAttrsToList (
        name: grammar: "ln -s ${grammar}/parser $out/${lib.removePrefix "tree-sitter-" name}.so"
      ) grammars;
    in
    (runCommand "treesitter-grammars" { } ''
      mkdir -p $out
      ${lib.concatStringsSep "\n" symlinks}
    '').overrideAttrs
      (_: {
        passthru.rev = vimPlugins.nvim-treesitter.src.rev;
      });
  lspEnv = buildEnv {
    name = "lsp-servers";
    paths = nvim-lsp-packages;
  };
  name = "mvim";
in
writeShellApplication {
  inherit name;
  text = ''
    set -efux
    unset VIMINIT
    export PATH="${pkgs.coreutils}/bin:${lspEnv}/bin:${neovim}/bin:$PATH"
    export NVIM_APPNAME=${name}

    XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
    XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}

    # Safety checks for required variables
    if [ -z "$XDG_CONFIG_HOME" ] || [ -z "$NVIM_APPNAME" ]; then
      echo "Error: XDG_CONFIG_HOME or NVIM_APPNAME is not set" >&2
      exit 1
    fi

    # Ensure we're not accidentally deleting root directory
    CONFIG_DIR="$XDG_CONFIG_HOME/$NVIM_APPNAME"
    if [ "$CONFIG_DIR" = "/" ] || [ -z "$CONFIG_DIR" ]; then
      echo "Error: Invalid config directory path" >&2
      exit 1
    fi

    mkdir -p "$CONFIG_DIR" "$XDG_DATA_HOME"
    chmod -R u+w "$CONFIG_DIR"
    rm -rf "$CONFIG_DIR"
    cp -arfT '${../.}' "$CONFIG_DIR"
    chmod -R u+w "$CONFIG_DIR"
    echo "${treesitter-grammars.rev}" > "$CONFIG_DIR/treesitter-rev"

    if ! grep -q "${treesitter-grammars.rev}" "$CONFIG_DIR/lazy-lock.json"; then
      nvim --headless "+Lazy! update" +qa
    else
      nvim --headless -c 'quitall'
    fi

    mkdir -p "$XDG_DATA_HOME/$NVIM_APPNAME/lib/" "$XDG_DATA_HOME/$NVIM_APPNAME/site/"

    PARSER_DIR="$XDG_DATA_HOME/$NVIM_APPNAME/site/parser"

    # If the parser directory exists, move it to a backup location instead of trying to modify it
    if [ -d "$PARSER_DIR" ]; then
      mv "$PARSER_DIR" "$PARSER_DIR.old" 2>/dev/null || true
    fi

    # Create the symlink using GNU ln
    ln -sfn "${treesitter-grammars}" "$PARSER_DIR"

    exec nvim "$@"
  '';
}
