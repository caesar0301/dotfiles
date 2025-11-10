-- Unified Plugin Configuration for Lazy.nvim
-- Each plugin has its own file for better organization and maintainability

return {
	-- Import dependencies and simple plugins
	{ import = "plugins._dependencies" },

	-- Import major plugins (alphabetically organized)
	{ import = "plugins.barbar" },
	{ import = "plugins.codecompanion" },
	{ import = "plugins.conform" },
	{ import = "plugins.fzf-lua" },
	{ import = "plugins.gitignore" },
	{ import = "plugins.gitsigns" },
	{ import = "plugins.lspkind" },
	{ import = "plugins.lualine" },
	{ import = "plugins.nvim-autopairs" },
	{ import = "plugins.nvim-cmp" },
	{ import = "plugins.nvim-lspconfig" },
	{ import = "plugins.nvim-r" },
	{ import = "plugins.nvim-tree" },
	{ import = "plugins.nvim-treesitter" },
	{ import = "plugins.nvim-web-devicons" },
	{ import = "plugins.tagbar" },
	{ import = "plugins.telescope" },
	{ import = "plugins.toggleterm" },
	{ import = "plugins.vim-gitgutter" },
	{ import = "plugins.vimtex" },
	{ import = "plugins.vlime" },
}
