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
    },
    { "b0o/schemastore.nvim" },
    {
        "Mythos-404/xmake.nvim",
        version = "^3",
        lazy = true,
        event = "BufReadPost",
        config = true,
    },
    {
        "madskjeldgaard/cppman.nvim",
        requires = {
            { "MunifTanjim/nui.nvim" }, -- Required dependency for the UI
        },
        config = function()
            local cppman = require "cppman"
            cppman.setup()

            -- Keymaps for easy access
            vim.keymap.set("n", "<leader>cm", function()
                cppman.open_cppman_for(vim.fn.expand "<cword>") -- Open man page for the word under the cursor
            end, { desc = "Open C++ man page for word under cursor" })

            vim.keymap.set("n", "<leader>cc", function()
                cppman.input() -- Open search prompt
            end, { desc = "Open C++ man page search prompt" })
        end,
    },

    -- { "cordx56/rustowl", dependencies = { "neovim/nvim-lspconfig" } },
}
