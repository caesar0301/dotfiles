-- Plugin dependencies and simple plugins without configuration
return {
	-- Theme
	{
		"tomasiser/vim-code-dark",
		priority = 1000, -- Load colorscheme early
		config = function()
			vim.cmd.colorscheme("codedark")
		end,
	},

	-- LSP dependencies
	{ "nvim-lua/lsp-status.nvim", lazy = true },
	{ "rmagatti/goto-preview", lazy = true, dependencies = { "rmagatti/logger.nvim" } },
	{ "rmagatti/logger.nvim", lazy = true },
	{ "hrsh7th/cmp-nvim-lsp", lazy = true },
	{ "hrsh7th/cmp-buffer", lazy = true },
	{ "hrsh7th/cmp-path", lazy = true },
	{ "hrsh7th/cmp-cmdline", lazy = true },
	{ "saadparwaiz1/cmp_luasnip", lazy = true },
	{ "lukas-reineke/cmp-under-comparator", lazy = true },
	{
		"L3MON4D3/LuaSnip",
		lazy = true,
		build = "make install_jsregexp",
	},
	-- lspkind-nvim (will be configured inline below)

	-- Treesitter dependencies
	{ "nvim-treesitter/nvim-treesitter-refactor", lazy = true },

	-- Telescope dependencies
	{ "nvim-lua/plenary.nvim", lazy = true },
	{ "BurntSushi/ripgrep", lazy = true },
	{ "nvim-telescope/telescope-fzf-native.nvim", lazy = true },
	{ "sharkdp/fd", lazy = true },

	-- FZF binary
	{ "junegunn/fzf", lazy = true, build = ":call fzf#install()" },

	-- Web dev icons (will be configured inline below)

	-- R language dependencies
	{ "jalvesaq/cmp-nvim-r", lazy = true },
	{ "jalvesaq/colorout", lazy = true },

	-- Vlime dependencies
	{ "HiPhish/nvim-cmp-vlime", lazy = true },
	{ "kovisoft/paredit", lazy = true },

	-- Simple plugins without config
	{ "wellle/context.vim", event = "BufReadPost" },
	{ "plasticboy/vim-markdown", ft = "markdown" },
	{ "MeanderingProgrammer/render-markdown.nvim", ft = "markdown" },
	{ "editorconfig/editorconfig-vim", event = { "BufReadPre", "BufNewFile" } },
	{ "pangloss/vim-javascript", ft = { "javascript", "javascriptreact" } },
	{ "neovimhaskell/haskell-vim", ft = "haskell" },
	{ "nvie/vim-flake8", ft = "python" },
	{ "vim-ruby/vim-ruby", ft = "ruby" },
	{ "chrisbra/csv.vim", ft = "csv" },
	{ "godlygeek/tabular", cmd = "Tabularize" },
	{ "tpope/vim-commentary", keys = { { "gc", mode = { "n", "v" } }, { "gcc", mode = "n" }, { "gcap", mode = "n" } } },
	{
		"mfussenegger/nvim-dap",
		cmd = { "DapToggleBreakpoint", "DapContinue" },
		keys = {
			{ "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle breakpoint" },
			{ "<leader>dc", "<cmd>DapContinue<cr>", desc = "Continue debugging" },
		},
	},
	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp", "objc", "objcpp" },
		dependencies = { "neovim/nvim-lspconfig" },
	},
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	{
		"terryma/vim-expand-region",
		event = "VeryLazy",
		config = function()
			vim.keymap.set("v", "+", "<Plug>(expand_region_expand)", { desc = "Expand visual selection" })
			vim.keymap.set("v", "_", "<Plug>(expand_region_shrink)", { desc = "Shrink visual selection" })
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup({})
		end,
	},
	{
		"m-demare/hlargs.nvim",
		event = "BufReadPost",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("hlargs").setup()
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "v3.1.3",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	{
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
	},
	{
		"Civitasv/cmake-tools.nvim",
		ft = { "cmake", "cpp", "c" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("cmake-tools").setup({})
		end,
	},
	{
		"rust-lang/rust.vim",
		ft = "rust",
		cond = function()
			if not SUPPORTS_MODERN_PLUGINS then
				vim.defer_fn(function()
					if IS_MAC then
						vim.notify("Rust plugin disabled: Not supported on macOS", vim.log.levels.WARN)
					else
						vim.notify(
							"Rust plugin disabled: Kernel version " .. KERNEL_VERSION .. " < 5.0",
							vim.log.levels.WARN
						)
					end
				end, 100)
				return false
			end
			return true
		end,
	},
	{
		"antosha417/nvim-lsp-file-operations",
		lazy = true,
	},
	{
		"echasnovski/mini.base16",
		lazy = true,
	},
}
