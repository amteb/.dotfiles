local function recording()
	local reg = vim.fn.reg_recording()
	if reg ~= "" then
		return reg
	end
	return ""
end

local function has_messages()
	if #vim.fn.filter(vim.fn.getmessages(), "v:val !~ '^E121:'") > 0 then
		return "󰍡" -- or any icon you prefer
	end
	return ""
end

return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local colors = require("monokai-pro.colorscheme")
		vim.opt.cmdheight = 0 -- Minimize command line space
		vim.opt.laststatus = 3 -- Global statusline
		local theme = {
			normal = {
				a = { bg = colors.base.yellow, fg = colors.base.black, gui = "bold" },
				b = { bg = colors.base.background, fg = colors.base.yellow },
				c = { bg = colors.base.background, fg = colors.statusBar.activeForeground },
			},
			insert = {
				a = { bg = colors.base.green, fg = colors.base.black, gui = "bold" },
				b = { bg = colors.base.background, fg = colors.base.green },
				c = { bg = colors.base.background, fg = colors.statusBar.activeForeground },
			},
			visual = {
				a = { bg = colors.base.magenta, fg = colors.base.black, gui = "bold" },
				b = { bg = colors.base.background, fg = colors.base.magenta },
				c = { bg = colors.base.background, fg = colors.statusBar.activeForeground },
			},
			replace = {
				a = { bg = colors.base.red, fg = colors.base.black, gui = "bold" },
				b = { bg = colors.base.background, fg = colors.base.red },
				c = { bg = colors.base.background, fg = colors.statusBar.activeForeground },
			},
			command = {
				a = { bg = colors.base.cyan, fg = colors.base.black, gui = "bold" },
				b = { bg = colors.base.background, fg = colors.base.cyan },
				c = { bg = colors.base.background, fg = colors.statusBar.activeForeground },
			},
			inactive = {
				a = { bg = colors.base.background, fg = colors.base.dimmed1 },
				b = { bg = colors.base.background, fg = colors.base.dimmed1 },
				c = { bg = colors.base.background, fg = colors.base.dimmed1 },
			},
		}

		require("lualine").setup({
			options = {
				theme = theme,
				component_separators = "",
				section_separators = "",
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							return str:sub(1, 1)
						end,
					},
				},
				lualine_b = {
					{
						"filename",
						path = 1,
						symbols = {
							modified = "●",
							readonly = "",
							unnamed = "",
						},
					},
				},
				lualine_c = {
					{
						"branch",
						icon = "󰘬",
					},
					{ "diff" },
					{ has_messages },
				},
				lualine_x = {
					{
						"diagnostics",
						sections = { "error", "warn", "info", "hint" },
					},

					{ "lsp_status" },
				},
				lualine_y = {
					"filetype",
				},
				lualine_z = {
					{ recording },
				},
			},
			extensions = {
				"fzf",
				"lazy",
				"mason",
				"neo-tree",
				"nvim-dap-ui",
			},
		})
	end,
}
