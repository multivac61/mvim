return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                emmet_ls = {
                    filetypes = {
                        "html",
                        "css",
                        "heex",
                        "eex",
                        "elixir",
                        "javascript",
                        "javascriptreact",
                        "typescript",
                        "typescriptreact",
                    },
                },
            },
        },
    },
}
