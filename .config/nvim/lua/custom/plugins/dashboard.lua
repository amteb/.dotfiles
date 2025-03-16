return {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    priority = 999,
    config = function()
        require("dashboard").setup {
            theme = "hyper",
            config = {
                week_header = {
                    enable = true,
                },
                shortcut = {
                    {
                        desc = "󰒲 Lazy",
                        group = "@property",
                        action = "Lazy",
                        key = "L",
                    },
                    {
                        desc = " Mason",
                        group = "@property",
                        action = "Mason",
                        key = "M",
                    },
                    {
                        icon = " ",
                        icon_hl = "@variable",
                        desc = "Files",
                        group = "Label",
                        action = "Telescope find_files",
                        key = "F",
                    },
                    {
                        desc = " Current Dir",
                        group = "DiagnosticHint",
                        action = function()
                            vim.cmd("Neotree dir=" .. vim.fn.getcwd())
                        end,
                        key = ".",
                    },
                    {
                        desc = " Home",
                        group = "DiagnosticHint",
                        action = "Neotree dir=~",
                        key = "H",
                    },
                    {
                        desc = " Dev",
                        group = "DiagnosticHint",
                        action = "Neotree dir=~/dev",
                        key = "D",
                    },
                    {
                        desc = " Config",
                        group = "Number",
                        action = "Neotree dir=~/.config/nvim",
                        key = "n",
                    },
                    {
                        desc = " dotfiles",
                        group = "Number",
                        action = "Neotree dir=~/.dotfiles",
                        key = "d",
                    },
                },
            },
        }
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
