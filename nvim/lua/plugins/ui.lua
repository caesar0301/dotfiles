-- UI and Interface Plugins
return {
	-- Themes
	{
		"tomasiser/vim-code-dark",
		priority = 1000, -- Load colorscheme early
		config = function()
			vim.cmd.colorscheme("codedark")
		end,
	},

	-- Tabline with auto-sizing, clickable tabs, icons, highlighting etc.
	{
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
			vim.keymap.set(
				"n",
				"<A-C>",
				"<cmd>BufferCloseAllButCurrent<CR>",
				{ desc = "[barbar] Close all but current" }
			)
			vim.keymap.set("n", "<A-r>", "<cmd>BufferRestore<CR>", { desc = "[barbar] Restore last closed" })
			vim.keymap.set("n", "<C-p>", "<cmd>BufferPick<CR>", { desc = "[barbar] Magic buffer picker" })
			vim.keymap.set(
				"n",
				"<Space>bb",
				"<cmd>BufferOrderByBufferNumber<CR>",
				{ desc = "[barbar] Order buffers by number" }
			)
			vim.keymap.set("n", "<Space>bn", "<cmd>BufferOrderByName<CR>", { desc = "[barbar] Order buffers by name" })
			vim.keymap.set(
				"n",
				"<Space>bd",
				"<cmd>BufferOrderByDirectory<CR>",
				{ desc = "[barbar] Order buffers by dir" }
			)
			vim.keymap.set(
				"n",
				"<Space>bl",
				"<cmd>BufferOrderByLanguage<CR>",
				{ desc = "[barbar] Order buffers by lang" }
			)
			vim.keymap.set(
				"n",
				"<Space>bw",
				"<cmd>BufferOrderByWindowNumber<CR>",
				{ desc = "[barbar] Order buffers by window number" }
			)
		end,
	},

	-- Configure neovim statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-lua/lsp-status.nvim",
		},
		config = function()
			require("lualine").setup({
				options = {
					theme = "powerline_dark",
				},
			})
		end,
	},

	-- Folder and file tree view
	{
		"nvim-tree/nvim-tree.lua",
		cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"antosha417/nvim-lsp-file-operations",
			"echasnovski/mini.base16",
		},
		config = function()
			-- Load configuration from plugin/nvim-tree.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/nvim-tree.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end
		end,
	},

	-- Displays tags in a window, ordered by scope
	{
		"preservim/tagbar",
		cmd = "TagbarToggle",
		config = function()
			-- Load configuration from plugin/tagbar.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/tagbar.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end
			-- Keymaps for tagbar
			vim.keymap.set("n", "<leader>tt", ":TagbarToggle<CR>", { desc = "[tagbar] Toggle tagbar" })
			vim.keymap.set("n", "<F9>", ":TagbarToggle<CR>", { desc = "[tagbar] Toggle tagbar" })
		end,
	},

	-- shows the context of the currently visible buffer contents
	{
		"wellle/context.vim",
		event = "BufReadPost",
	},

	-- Expand visual selection incrementally
	{
		"terryma/vim-expand-region",
		event = "VeryLazy",
		config = function()
			vim.keymap.set("v", "+", "<Plug>(expand_region_expand)", { desc = "Expand visual selection" })
			vim.keymap.set("v", "_", "<Plug>(expand_region_shrink)", { desc = "Shrink visual selection" })
		end,
	},

	-- displays a popup with possible keybindings of the command you started typing
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup({})
		end,
	},

	-- easily manage multiple terminal windows
	{
		"akinsho/toggleterm.nvim",
		version = "v2.13.1",
		cmd = { "ToggleTerm", "TermExec" },
		keys = { "<C-\\>" },
		config = function()
			require("toggleterm").setup()
			-- Keymaps for toggleterm
			vim.keymap.set("n", "<leader>T", "<cmd>:ToggleTerm<cr>", { desc = "ToggleTerm" })

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
	},

	-- Web dev icons
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		config = function()
			-- Load configuration from plugin/web-devicons.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/web-devicons.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end
		end,
	},
}
