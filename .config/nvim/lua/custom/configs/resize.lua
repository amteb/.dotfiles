-- Window resize functionality
-- Makes resizing windows more user-friendly

local M = {}

function M.setup()
    vim.keymap.set("n", "<C-w>r", function()
        -- Enter a temporary "resize mode"
        vim.notify("RESIZE MODE: +/- (height), </> (width), ESC to exit", vim.log.levels.INFO)

        -- Save the current mapping state for restoration
        local original_mappings = {}
        local keys_to_map = { "+", "-", "<", ">", "h", "j", "k", "l", "<Esc>" }

        for _, key in ipairs(keys_to_map) do
            original_mappings[key] = vim.fn.maparg(key, "n", false, true)
        end

        -- Define resize mode mappings
        vim.keymap.set("n", "+", "<C-w>+", { nowait = true })
        vim.keymap.set("n", "-", "<C-w>-", { nowait = true })
        vim.keymap.set("n", ">", "<C-w>>", { nowait = true })
        vim.keymap.set("n", "<", "<C-w><", { nowait = true })
        vim.keymap.set("n", "k", "<C-w>+", { nowait = true })
        vim.keymap.set("n", "j", "<C-w>-", { nowait = true })
        vim.keymap.set("n", "l", "<C-w>>", { nowait = true })
        vim.keymap.set("n", "h", "<C-w><", { nowait = true })

        -- Exit resize mode
        vim.keymap.set("n", "<Esc>", function()
            -- Restore original mappings
            for key, mapping in pairs(original_mappings) do
                if next(mapping) ~= nil then
                    -- There was a previous mapping, restore it
                    vim.fn.mapset("n", false, mapping)
                else
                    -- There was no previous mapping, clear it
                    vim.keymap.del("n", key)
                end
            end

            vim.notify("Exited resize mode", vim.log.levels.INFO)
        end, { nowait = true })
    end, { desc = "Enter window resize mode" })
end

return M
