return {
    "echasnovski/mini.nvim",
    config = function()
        -- Better Around/Inside textobjects
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
        --  - ci'  - [C]hange [I]nside [']quote
        require("mini.ai").setup { n_lines = 500 }

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --  - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        --  - sd'   - [S]urround [D]elete [']quotes
        --  - sr)'  - [S]urround [R]eplace [)] [']
        require("mini.surround").setup()

        -- Move lines/selections with Alt+hjkl
        require("mini.move").setup {
            mappings = {
                left = "<M-h>",
                right = "<M-l>",
                down = "<M-j>",
                up = "<M-k>",
                line_left = "<M-h>",
                line_right = "<M-l>",
                line_down = "<M-j>",
                line_up = "<M-k>",
            },
        }

        -- [b, ]b for buffers, [c, ]c for comments, [x, ]x for conflicts, etc.
        require("mini.bracketed").setup()

        -- Auto-pairs for brackets, quotes, etc.
        require("mini.pairs").setup()

        -- Comment with gc (gcc for line, gc in visual)
        require("mini.comment").setup()

        -- Highlight patterns: hex colors, TODO/FIXME/etc.
        local hipatterns = require "mini.hipatterns"
        hipatterns.setup {
            highlighters = {
                fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
                hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
                todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
                note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
                hex_color = hipatterns.gen_highlighter.hex_color(),
            },
        }
    end,
}
