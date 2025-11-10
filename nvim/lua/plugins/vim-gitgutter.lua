-- Show git diff markers in the sign column
return {
	"airblade/vim-gitgutter",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		-- Keymaps for gitgutter
		vim.keymap.set("n", "<leader>gu", "<cmd>GitGutterToggle<cr>", { desc = "Toggle GitGutter" })
	end,
}
