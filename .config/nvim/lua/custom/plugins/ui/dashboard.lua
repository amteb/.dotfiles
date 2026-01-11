return {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    priority = 999,
    config = function()
        local function get_header()
            local cwd = vim.fn.getcwd()
            local dir_name = vim.fn.fnamemodify(cwd, ":t")
            if dir_name == "" then
                dir_name = cwd
            end

            local ok, result = pcall(vim.fn.systemlist, "figlet -w 100 -f colossal " .. dir_name)
            if ok and result and #result > 0 then
                return result
            end

            return { dir_name }
        end

        require("dashboard").setup {
            theme = "hyper",
            disable_move = true,
            shortcut_type = "number",
            disable = { winbar = true, statusline = true, tabline = true },
            config = {
                header = get_header(),
                packages = {
                    enabled = false,
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
