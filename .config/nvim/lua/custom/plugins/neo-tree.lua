-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

-- nvim/lua/custom/plugins/neo-tree.lua
return {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    event = "BufWinEnter",
    keys = {
        { "\\", ":Neotree float reveal<CR>", desc = "NeoTree float reveal", silent = true },
    },
    opts = {
        popup_border_style = "rounded",
        close_if_last_window = true,
        window = {
            mappings = {
                ["\\"] = "close_window",
            },
            position = "float",
        },
        filesystem = {
            filtered_items = {
                visible = true,
                hide_dotfiles = false,
                hide_gitignored = false,
            },
            window = {
                mappings = {
                    ["\\"] = "close_window",
                },
                position = "float",
            },
        },
    },
    config = function(_, opts)
        -- Directly setup with the float position
        require("neo-tree").setup(opts)
    end,
}
