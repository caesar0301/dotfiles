-- Easily manage multiple terminal windows
return {
	"akinsho/toggleterm.nvim",
	version = "v2.13.1",
	cmd = { "ToggleTerm", "TermExec" },
	keys = {
		{ "<C-\\>", desc = "Toggle terminal" },
		{ "<leader>T", "<cmd>ToggleTerm<cr>", desc = "ToggleTerm" },
	},
	config = function()
		require("toggleterm").setup()

		-- Terminal mode navigation (move in/out of terminal splits)
		function _G.set_terminal_keymaps()
			local opts = { buffer = 0 }
			vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
			vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
			vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
			vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
			vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
			vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
		end
		-- Only apply these mappings for toggleterm buffers
		vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
	end,
}
