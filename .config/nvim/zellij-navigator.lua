-- Zellij Navigator - Seamless navigation between Neovim and Zellij
-- Place this file in ~/.config/nvim/ and source it in your init.lua
-- Add: require('zellij-navigator')

local function is_zellij()
  return vim.env.ZELLIJ ~= nil
end

local function navigate(direction)
  local curr_win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. direction)

  -- If we're still in the same window, we're at the edge
  -- So pass the navigation to Zellij
  if curr_win == vim.api.nvim_get_current_win() and is_zellij() then
    local directions = {
      h = 'left',
      j = 'down',
      k = 'up',
      l = 'right'
    }

    -- Send the navigation command to Zellij
    vim.fn.system('zellij action move-focus ' .. directions[direction])
  end
end

-- Set up keybindings
vim.keymap.set('n', '<C-h>', function() navigate('h') end, { silent = true, desc = 'Navigate left' })
vim.keymap.set('n', '<C-j>', function() navigate('j') end, { silent = true, desc = 'Navigate down' })
vim.keymap.set('n', '<C-k>', function() navigate('k') end, { silent = true, desc = 'Navigate up' })
vim.keymap.set('n', '<C-l>', function() navigate('l') end, { silent = true, desc = 'Navigate right' })

return {}
