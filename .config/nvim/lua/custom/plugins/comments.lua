return {

    --  This is equivalent to:
    --    require('Comment').setup({})
    -- "gc" to comment visual regions/lines
    -- Use `opts = {}` to force a plugin to be loaded.

    {
        "numToStr/Comment.nvim",
        opts = {},
    },
    {
        "folke/todo-comments.nvim",
        event = "VimEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = false },
    },
}
