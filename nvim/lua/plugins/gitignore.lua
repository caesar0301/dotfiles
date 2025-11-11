-- Generating .gitignore files
return {
	"wintermute-cell/gitignore.nvim",
	cmd = { "Gitignore" },
	keys = {
		{
			"<leader>gi",
			function()
				require("gitignore").generate()
			end,
			desc = "Add gitignore",
		},
	},
	dependencies = {
		"nvim-telescope/telescope.nvim", -- optional: for multi-select
	},
	config = function() end,
}
