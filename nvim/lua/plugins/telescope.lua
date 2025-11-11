-- Highly extendable fuzzy finder over file and symbols
return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	cmd = "Telescope",
	keys = {
		{ "<leader>tf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
		{ "<leader>tg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
		{ "<leader>tb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
		{ "<leader>th", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files()
			end,
			desc = "[telescope] Find files",
		},
		{
			"<leader>fw",
			function()
				require("telescope.builtin").grep_string()
			end,
			desc = "[telescope] Find current word",
		},
		{
			"<leader>fg",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "[telescope] Search everywhere",
		},
		{
			"<leader>fd",
			function()
				local dir = vim.fn.input("Directory: ", vim.fn.expand("%:p:h"), "dir")
				require("telescope.builtin").live_grep({ cwd = dir })
			end,
			desc = "[telescope] Search in directory",
		},
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
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				-- Use ripgrep with sensible defaults
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden", -- Search hidden files (respect .gitignore)
					"--glob=!.git/", -- Ignore .git directory
				},
				-- General Telescope settings
				prompt_prefix = "🔍 ",
				selection_caret = "➤ ",
				entry_prefix = "  ",
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
					vertical = { mirror = false },
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},
				file_ignore_patterns = { "node_modules", "build", "dist", "yarn.lock" },
				path_display = { "truncate" },
				mappings = {
					i = {
						["<esc>"] = actions.close,
						["<C-n>"] = actions.cycle_history_next,
						["<C-p>"] = actions.cycle_history_prev,
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
						["<C-c>"] = actions.close,
						["<CR>"] = actions.select_default,
					},
					n = {
						["<esc>"] = actions.close,
						["j"] = actions.move_selection_next,
						["k"] = actions.move_selection_previous,
						["<CR>"] = actions.select_default,
					},
				},
			},
			pickers = {
				-- Customize grep_string to match whole words
				grep_string = {
					additional_args = { "--word-regexp" }, -- Match whole words
					word_match = "-w", -- Alternative for older rg versions
				},
				find_files = {
					hidden = true, -- Show hidden files
					find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--exclude", ".git" },
				},
			},
			extensions = {
				file_browser = {
					theme = "ivy",
					-- disables netrw and use telescope-file-browser in its place
					hijack_netrw = true,
				},
			},
		})
	end,
}
