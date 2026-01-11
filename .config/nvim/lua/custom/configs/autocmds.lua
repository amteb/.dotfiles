-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
--
-- Set 'keywordprg' for C/C++ file types to use cppman
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = { "c", "cpp" },
--     command = "setlocal keywordprg=cppman",
-- })
