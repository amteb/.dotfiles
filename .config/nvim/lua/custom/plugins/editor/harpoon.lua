return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        local conf = require("telescope.config").values
        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end

            require("telescope.pickers")
                .new({}, {
                    prompt_title = "Harpoon",
                    finder = require("telescope.finders").new_table({
                        results = file_paths,
                    }),
                    previewer = conf.file_previewer({}),
                    sorter = conf.generic_sorter({}),
                })
                :find()
        end

        -- Add current file to Harpoon
        vim.keymap.set("n", "<leader>pa", function()
            harpoon:list():add()
        end, { desc = "Har[P]oon [A]dd" })

        -- Remove current file from Harpoon
        vim.keymap.set("n", "<leader>pr", function()
            harpoon:list():remove()
        end, { desc = "Har[P]oon [R]emove current file" })

        -- Clear all Harpoon marks
        vim.keymap.set("n", "<leader>pc", function()
            harpoon:list():clear()
        end, { desc = "Har[P]oon [C]lear all" })

        -- Toggle Harpoon quick menu
        vim.keymap.set("n", "<leader>pm", function()
            toggle_telescope(harpoon:list())
        end, { desc = "Har[P]oon [M]enu" })

        -- Navigation to specific Harpoon marks
        vim.keymap.set("n", "<leader>p1", function()
            harpoon:list():select(1)
        end, { desc = "Har[P]oon slot [1]" })

        vim.keymap.set("n", "<leader>p2", function()
            harpoon:list():select(2)
        end, { desc = "Har[P]oon slot [2]" })

        vim.keymap.set("n", "<leader>p3", function()
            harpoon:list():select(3)
        end, { desc = "Har[P]oon slot [3]" })

        vim.keymap.set("n", "<leader>p4", function()
            harpoon:list():select(4)
        end, { desc = "Har[P]oon slot [4]" })

        -- Navigate through Harpoon marks
        vim.keymap.set("n", "<leader>pp", function()
            harpoon:list():prev()
        end, { desc = "Har[P]oon [P]revious" })

        vim.keymap.set("n", "<leader>pn", function()
            harpoon:list():next()
        end, { desc = "Har[P]oon [N]ext" })

        -- Toggle Harpoon quick menu with current file focused
        vim.keymap.set("n", "<leader>pf", function()
            local list = harpoon:list()
            local current_file = vim.fn.expand("%:p")
            local current_index = nil

            -- Find the index of the current file
            for i, item in ipairs(list.items) do
                if item.value == current_file then
                    current_index = i
                    break
                end
            end

            -- Function to show telescope with current file focused
            local function toggle_telescope_with_index(selection_index)
                local file_paths = {}
                for _, item in ipairs(list.items) do
                    table.insert(file_paths, item.value)
                end

                require("telescope.pickers")
                    .new({}, {
                        prompt_title = "Harpoon",
                        finder = require("telescope.finders").new_table({
                            results = file_paths,
                            selection = selection_index,
                        }),
                        previewer = require("telescope.config").values.file_previewer({}),
                        sorter = require("telescope.config").values.generic_sorter({}),
                    })
                    :find()
            end

            if current_index then
                toggle_telescope_with_index(current_index)
            else
                toggle_telescope(list)
            end
        end, { desc = "Har[P]oon [F]ind current" })
    end,
}
