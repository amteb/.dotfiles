return {
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
}
