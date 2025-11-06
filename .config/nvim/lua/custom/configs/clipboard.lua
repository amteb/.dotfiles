local M = {}

function M.setup()
	local function is_wsl()
		local handle = io.popen("uname -r")
		if handle then
			local result = handle:read("*a")
			handle:close()
			return result:match("microsoft") or result:match("WSL")
		end
		return false
	end

	if vim.fn.has("wsl") == 1 or is_wsl() then
		-- WSL configuration
		vim.g.clipboard = {
			name = "win32yank-wsl",
			copy = {
				["+"] = "win32yank.exe -i --crlf",
				["*"] = "win32yank.exe -i --crlf",
			},
			paste = {
				["+"] = "win32yank.exe -o --lf",
				["*"] = "win32yank.exe -o --lf",
			},
		}
	elseif vim.fn.has("mac") == 1 then
		-- macOS configuration
		vim.g.clipboard = {
			name = "pbcopy",
			copy = {
				["+"] = "pbcopy",
				["*"] = "pbcopy",
			},
			paste = {
				["+"] = "pbpaste",
				["*"] = "pbpaste",
			},
		}
	end
	-- For regular Linux or other systems, Neovim will use its default clipboard detection

	-- Don't sync system clipboard with default register
	-- Use explicit registers for system clipboard:
	--   "+y to copy to system clipboard
	--   "+p to paste from system clipboard
	-- Regular y/d/p will use internal registers only
	vim.opt.clipboard = ""
end

return M
