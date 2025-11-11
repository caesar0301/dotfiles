-- Show git diff markers in the sign column
return {
	"airblade/vim-gitgutter",
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{ "<leader>gu", "<cmd>GitGutterToggle<cr>", desc = "Toggle GitGutter" },
	},
	config = function() end,
}
