-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

require("custom.configs.options")
require("custom.configs.keymaps")
require("custom.configs.autocmds")
require("custom.configs.clipboard").setup()
require("custom.configs.resize").setup()
require("custom.configs.filetypes")
