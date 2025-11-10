-- Tabline with auto-sizing, clickable tabs, icons, highlighting etc.
return {
	"romgrk/barbar.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"lewis6991/gitsigns.nvim",
	},
	config = function()
		-- Keymaps for barbar
		vim.keymap.set("n", "<A-,>", "<cmd>BufferPrevious<CR>", { desc = "[barbar] Previous buffer" })
		vim.keymap.set("n", "<A-.>", "<cmd>BufferNext<CR>", { desc = "[barbar] Next buffer" })
		vim.keymap.set("n", "<A-c>", "<cmd>BufferClose<CR>", { desc = "[barbar] Close current buffer" })
		vim.keymap.set("n", "<A-C>", "<cmd>BufferCloseAllButCurrent<CR>", { desc = "[barbar] Close all but current" })
		vim.keymap.set("n", "<A-r>", "<cmd>BufferRestore<CR>", { desc = "[barbar] Restore last closed" })
		vim.keymap.set("n", "<C-p>", "<cmd>BufferPick<CR>", { desc = "[barbar] Magic buffer picker" })
		vim.keymap.set(
			"n",
			"<Space>bb",
			"<cmd>BufferOrderByBufferNumber<CR>",
			{ desc = "[barbar] Order buffers by number" }
		)
		vim.keymap.set("n", "<Space>bn", "<cmd>BufferOrderByName<CR>", { desc = "[barbar] Order buffers by name" })
		vim.keymap.set("n", "<Space>bd", "<cmd>BufferOrderByDirectory<CR>", { desc = "[barbar] Order buffers by dir" })
		vim.keymap.set("n", "<Space>bl", "<cmd>BufferOrderByLanguage<CR>", { desc = "[barbar] Order buffers by lang" })
		vim.keymap.set(
			"n",
			"<Space>bw",
			"<cmd>BufferOrderByWindowNumber<CR>",
			{ desc = "[barbar] Order buffers by window number" }
		)
	end,
}
