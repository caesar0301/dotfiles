-- Search and Navigation Enhancement Plugins
return {
	-- Improved fzf.vim written in lua
	{
		"ibhagwan/fzf-lua",
		cmd = {
			"FzfLua",
			"FzfLuaFiles",
			"FzfLuaBuffers",
			"FzfLuaGrep",
			"FzfLuaLiveGrep",
		},
		keys = {
			{ "<leader>ff", "<cmd>FzfLuaFiles<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>FzfLuaLiveGrep<cr>", desc = "Live grep" },
			{ "<leader>fb", "<cmd>FzfLuaBuffers<cr>", desc = "Find buffers" },
		},
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			{ "junegunn/fzf", build = ":call fzf#install()" },
		},
	},

	-- FZF binary
	{
		"junegunn/fzf",
		lazy = true,
		build = ":call fzf#install()",
	},

	-- Highly extendable fuzzy finder over file and symbols
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		cmd = "Telescope",
		keys = {
			{ "<leader>tf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>tg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<leader>tb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
			{ "<leader>th", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"BurntSushi/ripgrep",
			"nvim-telescope/telescope-fzf-native.nvim",
			"sharkdp/fd",
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			-- Load configuration from plugin/telescope.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/telescope.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end

			-- Additional Telescope keymaps
			vim.keymap.set(
				"n",
				"<leader>ff",
				require("telescope.builtin").find_files,
				{ desc = "[telescope] Find files" }
			)
			vim.keymap.set(
				"n",
				"<leader>fw",
				require("telescope.builtin").grep_string,
				{ desc = "[telescope] Find current word" }
			)
			vim.keymap.set(
				"n",
				"<leader>fg",
				require("telescope.builtin").live_grep,
				{ desc = "[telescope] Search everywhere" }
			)

			local function live_grep_directory()
				local dir = vim.fn.input("Directory: ", vim.fn.expand("%:p:h"), "dir")
				require("telescope.builtin").live_grep({ cwd = dir })
			end
			vim.keymap.set("n", "<leader>fd", live_grep_directory, { desc = "[telescope] Search in directory" })
		end,
	},

	-- Telescope dependencies
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "BurntSushi/ripgrep", lazy = true },
	{ "nvim-telescope/telescope-fzf-native.nvim", lazy = true },
	{ "sharkdp/fd", lazy = true },

	-- Better quickfix window in Neovim, polish old quickfix window
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
}
