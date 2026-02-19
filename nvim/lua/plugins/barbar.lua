-- Tabline with auto-sizing, clickable tabs, icons, highlighting etc.
return {
	"romgrk/barbar.nvim",
	event = "VeryLazy",
	keys = {
		-- Buffer navigation (Alt key - may require terminal configuration)
		{ "<A-,>", "<cmd>BufferPrevious<CR>", desc = "[barbar] Previous buffer" },
		{ "<A-.>", "<cmd>BufferNext<CR>", desc = "[barbar] Next buffer" },
		-- macOS-friendly alternatives using Cmd key
		{ "<D-,>", "<cmd>BufferPrevious<CR>", desc = "[barbar] Previous buffer" },
		{ "<D-.>", "<cmd>BufferNext<CR>", desc = "[barbar] Next buffer" },
		-- Buffer management
		{ "<A-c>", "<cmd>BufferClose<CR>", desc = "[barbar] Close current buffer" },
		{ "<A-C>", "<cmd>BufferCloseAllButCurrent<CR>", desc = "[barbar] Close all but current" },
		{ "<A-r>", "<cmd>BufferRestore<CR>", desc = "[barbar] Restore last closed" },
		-- Buffer picker
		{ "<C-p>", "<cmd>BufferPick<CR>", desc = "[barbar] Magic buffer picker" },
		-- Buffer ordering
		{ "<Space>bb", "<cmd>BufferOrderByBufferNumber<CR>", desc = "[barbar] Order buffers by number" },
		{ "<Space>bn", "<cmd>BufferOrderByName<CR>", desc = "[barbar] Order buffers by name" },
		{ "<Space>bd", "<cmd>BufferOrderByDirectory<CR>", desc = "[barbar] Order buffers by dir" },
		{ "<Space>bl", "<cmd>BufferOrderByLanguage<CR>", desc = "[barbar] Order buffers by lang" },
		{ "<Space>bw", "<cmd>BufferOrderByWindowNumber<CR>", desc = "[barbar] Order buffers by window number" },
	},
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"lewis6991/gitsigns.nvim",
	},
	config = function() end,
}
