-- Configure neovim statusline
return {
	"nvim-lualine/lualine.nvim",
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
