return {
    {
        -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "chomosuke/typst-preview.nvim",
        ft = "typst",
        version = "1.*",
        opts = {
            dependencies_bin = { ["tinymist"] = "tinymist" },
            invert_colors = "auto",
            -- open_cmd = "zathura %s",
            viewer = "zathura",
        },
    }, -- { "cordx56/rustowl", dependencies = { "neovim/nvim-lspconfig" } },
}
