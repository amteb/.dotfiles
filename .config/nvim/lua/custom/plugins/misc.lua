return { -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
    {
        "tpope/vim-sleuth",
    }, -- Detect tabstop and shiftwidth automatically
    {
        "ziglang/zig",
    },
    -- NOTE: Plugins can also be added by using a table,
    -- with the first argument being the link and the following
    -- keys can be used to configure plugin behavior/loading/etc.
    --
    -- Use `opts = {}` to force a plugin to be loaded.
    --
    --  This is equivalent to:
    --    require('Comment').setup({})
    -- "gc" to comment visual regions/lines
    {
        "numToStr/Comment.nvim",
        opts = {},
    },
    -- Here is a more advanced example where we pass configuration
    -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
    --    require('gitsigns').setup({ ... })
    --
    -- See `:help gitsigns` to understand what the configuration keys do
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
        },
    },
    -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
    --
    -- This is often very useful to both group configuration, as well as handle
    -- lazy loading plugins that don't need to be loaded immediately at startup.
    --
    -- For example, in the following configuration, we use:
    --  event = 'VimEnter'
    --
    -- which loads which-key before all the UI elements are loaded. Events can be
    -- normal autocommands events (`:help autocmd-events`).
    --
    -- Then, because we use the `config` key, the configuration only runs
    -- after the plugin has been loaded:
    --  config = function() ... end
    -- NOTE: Plugins can specify dependencies.
    --
    -- The dependencies are proper plugin specifications as well - anything
    -- you do for a plugin at the top level, you can do for a dependency.
    --
    -- Use the `dependencies` key to specify the dependencies of a particular plugin
    -- Highlight todo, notes, etc in comments
    {
        "folke/todo-comments.nvim",
        event = "VimEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = false },
    },
    { "akinsho/git-conflict.nvim", version = "*", config = true, opts = {} },
    { "HiPhish/debugpy.nvim" },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
        },
        config = function()
            -- Initialize the neotest module first
            local neotest = require "neotest"

            neotest.setup {
                adapters = {
                    require "neotest-python" {
                        -- python = function()
                        --     if vim.fn.isdirectory ".venv/bin" == 1 then
                        --         return ".venv/bin/python"
                        --     elseif vim.env.VIRTUAL_ENV then
                        --         return vim.env.VIRTUAL_ENV .. "/bin/python"
                        --     else
                        --         return "python"
                        --     end
                        -- end,
                        dap = { justMyCode = false },
                        args = { "--log-level", "DEBUG" },
                        runner = "pytest",
                        -- is_test_file = function(file_path)
                        --     -- More permissive pattern matching
                        --     return file_path:match "test_.+%.py$"
                        --         or file_path:match ".+_test%.py$"
                        --         or file_path:match "tests/.+%.py$"
                        --         or file_path:match "test/.+%.py$"
                        -- end,
                        pytest_discover_instances = true,
                    },
                },
                -- -- Enable debug logging
                -- log_level = vim.log.levels.DEBUG,
                -- -- Ensure summary is enabled
                -- summary = {
                --     enabled = true,
                --     expand_errors = true,
                --     follow = true,
                -- },
            }
        end,
        keys = {
            -- Test execution
            {
                "<leader>nr",
                function()
                    require("neotest").run.run()
                end,
                desc = "[N]eotest [R]un nearest",
            },
            {
                "<leader>nf",
                function()
                    require("neotest").run.run(vim.fn.expand "%")
                end,
                desc = "[N]eotest Run [F]ile",
            },
            {
                "<leader>na",
                function()
                    require("neotest").run.run(vim.fn.getcwd())
                end,
                desc = "[N]eotest Run [A]ll",
            },
            {
                "<leader>ns",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "[N]eotest [S]ummary toggle",
            },

            -- Test navigation
            {
                "<leader>nj",
                function()
                    require("neotest").jump.next { status = "failed" }
                end,
                desc = "[N]eotest [J]ump to next failed",
            },
            {
                "<leader>nk",
                function()
                    require("neotest").jump.prev { status = "failed" }
                end,
                desc = "[N]eotest [K]ump to prev failed",
            },

            -- Test output
            {
                "<leader>no",
                function()
                    require("neotest").output.open { enter = true }
                end,
                desc = "[N]eotest [O]utput show",
            },
            {
                "<leader>np",
                function()
                    require("neotest").output_panel.toggle()
                end,
                desc = "[N]eotest Output [P]anel toggle",
            },

            -- Test debugging
            {
                "<leader>nd",
                function()
                    require("neotest").run.run { strategy = "dap" }
                end,
                desc = "[N]eotest [D]ebug nearest",
            },

            -- Test execution control
            {
                "<leader>nx",
                function()
                    require("neotest").run.stop()
                end,
                desc = "[N]eotest Stop e[X]ecution",
            },
            {
                "<leader>nl",
                function()
                    require("neotest").run.run_last()
                end,
                desc = "[N]eotest Run [L]ast",
            },
        },
    },
    {
        "lervag/vimtex",
        lazy = false, -- we don't want to lazy load VimTeX
        -- tag = "v2.15", -- uncomment to pin to a specific release
        init = function()
            -- VimTeX configuration goes here, e.g.
            vim.g.vimtex_view_method = "mupdf"
        end,
    },
    -- { "wakatime/vim-wakatime", lazy = false },
}
