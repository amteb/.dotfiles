return {
    "VonHeikemen/fine-cmdline.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
        require("fine-cmdline").setup {
            cmdline = {
                enable_keymaps = true,
                smart_history = true,
                prompt = ": ",
            },
            popup = {
                position = {
                    row = "50%",
                    col = "50%",
                },
                size = {
                    width = "60%",
                },
                border = {
                    style = "double",
                },
                win_options = {
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                },
            },
        }
    end,
    vim.api.nvim_set_keymap("n", ":", "<cmd>FineCmdline<CR>", { noremap = true }),
}
