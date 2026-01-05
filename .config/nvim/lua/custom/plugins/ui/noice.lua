return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        {
            "rcarriga/nvim-notify",
            config = function()
                local notify = require "notify"
                notify.setup {
                    background_colour = "#0f0f0f",
                    timeout = 3000,
                    max_width = 50,
                    render = "compact",
                }
                vim.notify = notify
            end,
        },
    },
    opts = function()
        return {
            views = {
                cmdline_popup = {
                    position = {
                        row = vim.o.lines - 2, -- exactly one row above statusline
                        col = 0,
                    },
                    size = {
                        width = "100%",
                        height = "auto",
                    },
                    border = {
                        style = "none",
                    },
                    win_options = {
                        winhighlight = "Normal:Normal,FloatBorder:Normal",
                    },
                },
            },
            cmdline = {
                enabled = true,
                view = "cmdline_popup",
                format = {
                    cmdline = { pattern = "^:", icon = ":", lang = "vim" },
                    search_down = { kind = "search", pattern = "^/", icon = "/", lang = "regex" },
                    search_up = { kind = "search", pattern = "^%?", icon = "?", lang = "regex" },
                    filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
                    lua = {
                        pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
                        icon = "lua",
                        lang = "lua",
                    },
                    help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
                    input = {},
                },
            },
            messages = {
                enabled = true,
                view = "notify", -- default view for messages
                view_error = "notify", -- view for errors
                view_warn = "notify", -- view for warnings
                view_history = "messages", -- view for :messages
                view_search = "virtualtext", -- view for search count messages
            },
            popupmenu = {
                enabled = true,
                backend = "nui", -- backend to use to show regular cmdline completions
            },
            notify = {
                enabled = true,
                view = "notify",
            },
            lsp = {
                progress = {
                    enabled = true,
                    format = "lsp_progress",
                    format_done = "lsp_progress_done",
                    throttle = 1000 / 30,
                    view = "mini",
                },
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
                hover = {
                    enabled = true,
                    silent = false,
                    view = nil,
                    opts = {
                        border = {
                            style = "rounded",
                        },
                    },
                },
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = true,
                        trigger = true,
                        luasnip = true,
                        throttle = 50,
                    },
                    view = nil,
                    opts = {
                        border = {
                            style = "rounded",
                        },
                    },
                },
                message = {
                    enabled = true,
                    view = "notify",
                    opts = {},
                },
                documentation = {
                    view = "hover",
                    opts = {
                        lang = "markdown",
                        replace = true,
                        render = "plain",
                        format = { "{message}" },
                        win_options = { concealcursor = "n", conceallevel = 3 },
                    },
                },
            },
            presets = {
                bottom_search = false, -- use classic bottom search
                command_palette = false, -- don't position cmdline and popupmenu together
                long_message_to_split = true, -- long messages sent to split
                inc_rename = false, -- enables input dialog for inc-rename.nvim
                lsp_doc_border = true, -- add border to hover docs and signature help
            },
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        kind = "",
                        find = "written",
                    },
                    opts = { skip = true },
                },
                {
                    filter = {
                        event = "msg_show",
                        find = "E121:",
                    },
                    opts = { skip = true },
                },
            },
        }
    end,
}
