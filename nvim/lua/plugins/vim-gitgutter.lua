-- Show git diff markers in the sign column
local pins = require("plugin-pins")

return {
	"airblade/vim-gitgutter",
	version = pins.no_tags.version,
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{ "<leader>gu", "<cmd>GitGutterToggle<cr>", desc = "Toggle GitGutter" },
	},
	config = function() end,
}
