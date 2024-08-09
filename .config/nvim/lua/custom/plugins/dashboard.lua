return {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    priority = 999,
    config = function()
        require('dashboard').setup {
            theme = 'hyper',
            config = {
                week_header = {
                    enable = true,
                },
                shortcut = {
                    {
                        desc = '󰊳 Update',
                        group = '@property',
                        action = 'Lazy update',
                        key = 'U',
                    },
                    {
                        icon = ' ',
                        icon_hl = '@variable',
                        desc = 'Files',
                        group = 'Label',
                        action = 'Telescope find_files',
                        key = 'F',
                    },
                    {
                        desc = ' Home',
                        group = 'DiagnosticHint',
                        action = 'Neotree dir=~',
                        key = 'H',
                    },
                    {
                        desc = ' Dev',
                        group = 'DiagnosticHint',
                        action = 'Neotree dir=~/dev',
                        key = 'D',
                    },
                    {
                        desc = ' Config',
                        group = 'Number',
                        action = 'Neotree dir=~/.config/nvim',
                        key = 'N',
                    },
                    {
                        desc = ' dotfiles',
                        group = 'Number',
                        action = 'Neotree dir=~/.dotfiles',
                        key = '.',
                    },
                },
            },
        }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } }
}
