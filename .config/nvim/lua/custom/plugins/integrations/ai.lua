return {

    {
        "yetone/avante.nvim",
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        -- ⚠️ must add this setting! ! !
        build = vim.fn.has "win32" ~= 0
                and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
            or "make",
        event = "VeryLazy",
        version = false, -- Never set this value to "*"! Never!
        ---@module 'avante'
        ---@type avante.Config
        opts = {
            -- add any opts here
            -- this file can contain specific instructions for your project
            instructions_file = "avante.md",
            -- for example
            provider = "claude-code",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "nvim-mini/mini.pick", -- for file_selector provider mini.pick
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
            "ibhagwan/fzf-lua", -- for file_selector provider fzf
            "stevearc/dressing.nvim", -- for input provider dressing
            "folke/snacks.nvim", -- for input provider snacks
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- for providers='copilot'
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },

    -- {
    --     "olimorris/codecompanion.nvim",
    --     dependencies = {
    --         "nvim-lua/plenary.nvim",
    --         "nvim-treesitter/nvim-treesitter",
    --     },
    --     opts = {
    --         adapters = {
    --             claude_code = function()
    --                 return require("codecompanion.adapters").extend("claude_code", {})
    --             end,
    --         },
    --         strategies = {
    --             chat = { adapter = "claude_code" },
    --             inline = { adapter = "claude_code" },
    --         },
    --     },
    -- },
    --
    {
        "supermaven-inc/supermaven-nvim",
        opts = {},
    },

    -- ThePrimeagen/99: LLM-powered fill-in-function, visual selection prompts,
    -- and rule-based code generation. Disabled until blink.cmp support lands.
    -- {
    --     "ThePrimeagen/99",
    --     config = function()
    --         local _99 = require "99"
    --
    --         local cwd = vim.uv.cwd()
    --         local basename = vim.fs.basename(cwd)
    --         _99.setup {
    --             logger = {
    --                 level = _99.DEBUG,
    --                 path = "/tmp/" .. basename .. ".99.debug",
    --                 print_on_error = true,
    --             },
    --
    --             completion = {
    --                 custom_rules = {
    --                     "scratch/custom_rules/",
    --                 },
    --                 -- source = "cmp", -- blink.cmp not supported yet
    --             },
    --
    --             -- auto-discovers AGENT.md files walking up from the request file
    --             md_files = {
    --                 "AGENT.md",
    --             },
    --         }
    --
    --         vim.keymap.set("n", "<leader>9f", function()
    --             _99.fill_in_function()
    --         end)
    --         vim.keymap.set("v", "<leader>9v", function()
    --             _99.visual()
    --         end)
    --         vim.keymap.set("v", "<leader>9s", function()
    --             _99.stop_all_requests()
    --         end)
    --         vim.keymap.set("n", "<leader>9fd", function()
    --             _99.fill_in_function()
    --         end)
    --     end,
    -- },
}
