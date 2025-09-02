-- Git Integration Plugins
return {
	-- Show git diff markers in the sign column
	{
		"airblade/vim-gitgutter",
		event = { "BufReadPre", "BufNewFile" },
	},

	-- Git signs for better git integration
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- Load configuration from plugin/gitsigns.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/gitsigns.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end
		end,
	},

	-- Generating .gitignore files
	{
		"wintermute-cell/gitignore.nvim",
		cmd = { "Gitignore" },
		dependencies = {
			"nvim-telescope/telescope.nvim", -- optional: for multi-select
		},
	},
}
