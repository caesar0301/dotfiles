local pins = require("plugin-pins")

return {
	"MeanderingProgrammer/render-markdown.nvim",
	version = pins.render_markdown.version,
	ft = "markdown",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		{ "echasnovski/mini.nvim", version = pins.mini.version },
	},
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {},
}
