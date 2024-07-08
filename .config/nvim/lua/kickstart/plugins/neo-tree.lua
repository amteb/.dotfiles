-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

-- return {
--   'nvim-neo-tree/neo-tree.nvim',
--   version = '*',
--   dependencies = {
--     'nvim-lua/plenary.nvim',
--     'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
--     'MunifTanjim/nui.nvim',
--   },
--   cmd = 'Neotree float',
--   keys = {
--     { '\\', ':Neotree reveal float<CR>', { desc = 'NeoTree reveal' } },
--   },
--   opts = {
--     position = "float",
--     popup_border_style = "rounded",
--     close_if_last_window = true,
--     window = {
--       mappings = {
--         ['\\'] = 'close_window',
--       },
--       position = "float"
--     },
--     filesystem = {
--       filtered_items = {
--         visible = true,
--         hide_dotfiles = false,
--         hide_gitignored = false,
--       },
--       window = {
--         mappings = {
--           ['\\'] = 'close_window',
--         },
--         position = "float"
--       },
--     },
--   },
-- }
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree float',
  keys = {
    { '\\', ':Neotree reveal float<CR>', { desc = 'NeoTree reveal' } },
  },
  opts = {
    position = "float",
    popup_border_style = "rounded",
    close_if_last_window = true,
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
      position = "float"
    },
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
        position = "float"
      },
    },
  },
  config = function(_, opts)
    -- Adding debug prints
    print("Loading Neo-tree with opts: ", vim.inspect(opts))

    -- Setting up Neo-tree with options
    require('neo-tree').setup(opts)

    -- Debugging Neotree state
    vim.cmd([[
      augroup NeoTreeDebug
        autocmd!
        autocmd BufWinEnter * if &ft ==# 'neo-tree' | echom "Neo-tree opened" | endif
      augroup END
    ]])
  end,
}
