-- Native treesitter configuration for Neovim 0.12+
-- Parsers managed by nvim-treesitter plugin; highlighting/indent are native.

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
    callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'vim.treesitter'.indentexpr()"
        end
    end,
})
