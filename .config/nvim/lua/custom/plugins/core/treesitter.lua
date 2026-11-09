return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        config = function()
            local parsers = {
                "bash",
                "c",
                "cpp",
                "diff",
                "html",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "vim",
                "vimdoc",
                "query",
                "python",
                "toml",
                "yaml",
                "json",
                "sql",
                "make",
            }
            local installed = require("nvim-treesitter").get_installed()
            local to_install = vim.tbl_filter(function(p)
                return not vim.tbl_contains(installed, p)
            end, parsers)
            if #to_install > 0 then
                require("nvim-treesitter").install(to_install)
            end
        end,
    },
}
