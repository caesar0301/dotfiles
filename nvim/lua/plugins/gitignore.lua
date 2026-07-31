-- Generating .gitignore files
local pins = require("plugin-pins")

return {
	"wintermute-cell/gitignore.nvim",
	version = pins.no_tags.version,
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
