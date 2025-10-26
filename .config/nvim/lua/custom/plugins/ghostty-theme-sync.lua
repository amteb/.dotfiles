local M = {}

function M.is_ghostty()
    return vim.env.TERM_PROGRAM == "ghostty"
end

function M.get_active_theme()
    local config_path = vim.fn.expand "~/.config/ghostty/config"
    local file = io.open(config_path, "r")
    if not file then
        return nil
    end

    for line in file:lines() do
        local theme = line:match "^theme%s*=%s*(.+)$"
        if theme then
            file:close()
            return theme:gsub("^%s*(.-)%s*$", "%1")
        end
    end

    file:close()
    return nil
end

function M.find_theme_file(theme_name)
    local locations = {
        vim.fn.expand("~/.config/ghostty/themes/" .. theme_name),
        "/Applications/Ghostty.app/Contents/Resources/ghostty/themes/" .. theme_name,
        "/usr/share/ghostty/themes/" .. theme_name,
    }

    for _, path in ipairs(locations) do
        if vim.fn.filereadable(path) == 1 then
            return path
        end
    end
    return nil
end

function M.parse_ghostty_theme(filepath)
    local colors = { palette = {} }
    local file = io.open(filepath, "r")
    if not file then
        return nil
    end

    for line in file:lines() do
        local palette_idx, color = line:match "^palette%s*=%s*(%d+)=(.+)$"
        if palette_idx and color then
            colors.palette[tonumber(palette_idx)] = color:gsub("^%s*(.-)%s*$", "%1")
        else
            local key, value = line:match "^([%w-]+)%s*=%s*(.+)$"
            if key and value then
                colors[key] = value:gsub("^%s*(.-)%s*$", "%1")
            end
        end
    end

    file:close()
    return colors
end

function M.apply_colors(colors)
    vim.cmd "hi clear"
    if vim.fn.exists "syntax_on" then
        vim.cmd "syntax reset"
    end

    vim.o.termguicolors = true
    vim.g.colors_name = "ghostty_sync"

    local p = colors.palette
    local fg = colors.foreground
    local bg = colors.background

    local function hi(group, opts)
        local cmd = "hi " .. group
        if opts.fg then
            cmd = cmd .. " guifg=" .. opts.fg
        end
        if opts.bg then
            cmd = cmd .. " guibg=" .. opts.bg
        end
        if opts.sp then
            cmd = cmd .. " guisp=" .. opts.sp
        end
        if opts.style then
            cmd = cmd .. " gui=" .. opts.style
        end
        vim.cmd(cmd)
    end

    hi("Normal", { fg = fg, bg = bg })
    hi("NormalFloat", { fg = fg, bg = bg })
    hi("Comment", { fg = p[8], style = "italic" })
    hi("Constant", { fg = p[1] })
    hi("String", { fg = p[2] })
    hi("Character", { fg = p[2] })
    hi("Number", { fg = p[3] })
    hi("Boolean", { fg = p[3] })
    hi("Float", { fg = p[3] })
    hi("Identifier", { fg = p[4] })
    hi("Function", { fg = p[4] })
    hi("Statement", { fg = p[5] })
    hi("Conditional", { fg = p[5] })
    hi("Repeat", { fg = p[5] })
    hi("Label", { fg = p[5] })
    hi("Operator", { fg = fg })
    hi("Keyword", { fg = p[5] })
    hi("Exception", { fg = p[1] })
    hi("PreProc", { fg = p[6] })
    hi("Include", { fg = p[6] })
    hi("Define", { fg = p[6] })
    hi("Macro", { fg = p[6] })
    hi("Type", { fg = p[6] })
    hi("StorageClass", { fg = p[6] })
    hi("Structure", { fg = p[6] })
    hi("Special", { fg = p[3] })
    hi("SpecialChar", { fg = p[3] })
    hi("Delimiter", { fg = fg })
    hi("Error", { fg = p[1], bg = bg })
    hi("Todo", { fg = p[3], bg = bg, style = "bold" })
    hi("Cursor", { fg = colors["cursor-text"], bg = colors["cursor-color"] })
    hi("Visual", { fg = colors["selection-foreground"], bg = colors["selection-background"] })
    hi("VisualNOS", { fg = colors["selection-foreground"], bg = colors["selection-background"] })
    hi("Search", { fg = bg, bg = p[3] })
    hi("IncSearch", { fg = bg, bg = p[3] })
    hi("LineNr", { fg = p[8] })
    hi("CursorLineNr", { fg = p[11] })
    hi("StatusLine", { fg = fg, bg = p[0] })
    hi("StatusLineNC", { fg = p[8], bg = p[0] })
    hi("VertSplit", { fg = p[8] })
    hi("Pmenu", { fg = fg, bg = p[0] })
    hi("PmenuSel", { fg = bg, bg = p[4] })
    hi("PmenuSbar", { bg = p[8] })
    hi("PmenuThumb", { bg = fg })
    hi("DiffAdd", { fg = p[2], bg = bg })
    hi("DiffChange", { fg = p[3], bg = bg })
    hi("DiffDelete", { fg = p[1], bg = bg })
    hi("DiffText", { fg = p[4], bg = bg })
end

function M.setup()
    if not M.is_ghostty() then
        return
    end

    local theme_name = M.get_active_theme()
    if not theme_name then
        return
    end

    local theme_file = M.find_theme_file(theme_name)
    if not theme_file then
        return
    end

    local colors = M.parse_ghostty_theme(theme_file)
    if not colors then
        return
    end

    M.apply_colors(colors)
end

return M
