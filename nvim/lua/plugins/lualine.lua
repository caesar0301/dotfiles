-- Configure neovim statusline
local pins = require("plugin-pins")

return {
	"nvim-lualine/lualine.nvim",
	version = pins.lualine.version, -- only compat-nvim-* tags; track master
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"nvim-lua/lsp-status.nvim",
	},
	config = function()
		require("lualine").setup({
			options = {
				theme = "powerline_dark",
			},
		})
	end,
}
