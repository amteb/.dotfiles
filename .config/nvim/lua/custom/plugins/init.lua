--[[

    PLUGINS

--]]

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
-- Lazy.nvim will automatically load all plugin specs from these directories:
require("lazy").setup({
    -- Auto-import all custom plugins (organized by category)
    { import = "custom.plugins.core" },
    { import = "custom.plugins.editor" },
    { import = "custom.plugins.coding" },
    { import = "custom.plugins.lsp" },
    { import = "custom.plugins.ui" },
    { import = "custom.plugins.integrations" },

    -- Miscellaneous plugins
    { import = "custom.plugins.misc" },

    -- Kickstart plugins (explicit imports to avoid broken ones)
    require "kickstart.plugins.indent_line",
    require "kickstart.plugins.autopairs",
    require "kickstart.plugins.gitsigns",
}, {
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the
        -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = vim.g.have_nerd_font and {} or {
            runtime = "💻",
            require = "🌙",
            config = "🛠",
            plugin = "🔌",
            source = "📄",
            event = "📅",
            lazy = "💤 ",
            start = "🚀",
            keys = "🗝",
            task = "📌",
            init = "⚙",
            cmd = "⌘",
            ft = "📂",
        },
    },
})
