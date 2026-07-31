-- Plugin dependencies and simple plugins without configuration
-- Pins come from plugin-pins.lua (Neovim 0.12.4 + nvim-treesitter@main matrix)
local pins = require("plugin-pins")

return {
	-- Theme
	{ "tomasiser/vim-code-dark", version = pins.no_tags.version },

	-- LSP dependencies
	{ "nvim-lua/lsp-status.nvim", lazy = true, version = pins.no_tags.version },
	{
		"rmagatti/goto-preview",
		lazy = true,
		version = pins.goto_preview.version,
		dependencies = { "rmagatti/logger.nvim" },
	},
	{ "rmagatti/logger.nvim", lazy = true, version = pins.no_tags.version },
	{ "hrsh7th/cmp-nvim-lsp", lazy = true, version = pins.no_tags.version },
	{ "hrsh7th/cmp-buffer", lazy = true, version = pins.no_tags.version },
	{ "hrsh7th/cmp-path", lazy = true, version = pins.no_tags.version },
	{ "hrsh7th/cmp-cmdline", lazy = true, version = pins.no_tags.version },
	{ "saadparwaiz1/cmp_luasnip", lazy = true, version = pins.no_tags.version },
	{
		"lukas-reineke/cmp-under-comparator",
		lazy = true,
		version = pins.cmp_under_comparator.version,
	},
	{
		"L3MON4D3/LuaSnip",
		lazy = true,
		version = pins.luasnip.version,
		build = "make install_jsregexp",
	},

	-- Telescope dependencies
	{ "nvim-lua/plenary.nvim", lazy = true, version = pins.plenary.version },
	{ "BurntSushi/ripgrep", lazy = true, version = pins.ripgrep.version },
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		lazy = true,
		version = pins.telescope_fzf_native.version,
	},
	{ "sharkdp/fd", lazy = true, version = pins.fd.version },

	-- FZF binary
	{ "junegunn/fzf", lazy = true, version = pins.fzf.version, build = ":call fzf#install()" },

	-- R language dependencies
	{ "jalvesaq/cmp-nvim-r", lazy = true, version = pins.no_tags.version },
	{ "jalvesaq/colorout", lazy = true, version = pins.colorout.version },

	-- Vlime dependencies
	{ "HiPhish/nvim-cmp-vlime", lazy = true, version = pins.nvim_cmp_vlime.version },
	{ "kovisoft/paredit", lazy = true, version = pins.paredit.version },

	-- Simple plugins without config
	{ "wellle/context.vim", event = "BufReadPost", version = pins.no_tags.version },
	-- NOTE: plasticboy/vim-markdown removed — it is abandonware, breaks on
	-- Neovim 0.12+ (E884: function names cannot contain colons), and its
	-- ftdetect/mkd.vim sets filetype=mkd which prevented markdown-preview.nvim
	-- from loading. Use render-markdown.nvim + built-in markdown ft instead.
	{
		"editorconfig/editorconfig-vim",
		event = { "BufReadPre", "BufNewFile" },
		version = pins.editorconfig.version,
	},
	{
		"pangloss/vim-javascript",
		ft = { "javascript", "javascriptreact" },
		version = pins.vim_javascript.version,
	},
	{ "neovimhaskell/haskell-vim", ft = "haskell", version = pins.no_tags.version },
	{ "nvie/vim-flake8", ft = "python", version = pins.vim_flake8.version },
	{ "vim-ruby/vim-ruby", ft = "ruby", version = pins.no_tags.version },
	{ "chrisbra/csv.vim", ft = "csv", version = pins.no_tags.version },
	{ "godlygeek/tabular", cmd = "Tabularize", version = pins.tabular.version },
	{
		"tpope/vim-commentary",
		version = pins.vim_commentary.version,
		keys = { { "gc", mode = { "n", "v" } }, { "gcc", mode = "n" }, { "gcap", mode = "n" } },
	},
	{
		"mfussenegger/nvim-dap",
		version = pins.nvim_dap.version,
		cmd = { "DapToggleBreakpoint", "DapContinue" },
		keys = {
			{ "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle breakpoint" },
			{ "<leader>dc", "<cmd>DapContinue<cr>", desc = "Continue debugging" },
		},
	},
	{
		"p00f/clangd_extensions.nvim",
		version = pins.no_tags.version,
		ft = { "c", "cpp", "objc", "objcpp" },
		dependencies = { "neovim/nvim-lspconfig" },
	},
	{
		"kevinhwang91/nvim-bqf",
		-- tip required: release tags predate the nvim-treesitter@main shim
		version = pins.bqf.version,
		ft = "qf",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	{
		"terryma/vim-expand-region",
		version = pins.vim_expand_region.version,
		event = "VeryLazy",
		config = function()
			vim.keymap.set("v", "+", "<Plug>(expand_region_expand)", { desc = "Expand visual selection" })
			vim.keymap.set("v", "_", "<Plug>(expand_region_shrink)", { desc = "Shrink visual selection" })
		end,
	},
	{
		"folke/which-key.nvim",
		version = pins.which_key.version,
		event = "VeryLazy",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup({})
		end,
	},
	{
		"m-demare/hlargs.nvim",
		version = pins.hlargs.version,
		event = "BufReadPost",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("hlargs").setup()
		end,
	},
	{
		"kylechui/nvim-surround",
		version = pins.nvim_surround.version,
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	{
		-- NOTE: do NOT lazy-load via `cmd` — MarkdownPreview is a buffer-local
		-- command created by a FileType autocmd. Lazy's cmd loader runs the
		-- command before that autocmd fires, so it reports "not found after
		-- loading". Loading on `ft` ensures the command exists before use.
		"iamcco/markdown-preview.nvim",
		version = pins.markdown_preview.version,
		ft = "markdown",
		build = "cd app && bash install.sh",
	},
	{
		"Civitasv/cmake-tools.nvim",
		version = pins.no_tags.version,
		ft = { "cmake", "cpp", "c" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("cmake-tools").setup({})
		end,
	},
	{
		"rust-lang/rust.vim",
		version = pins.no_tags.version,
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
		version = pins.no_tags.version,
	},
	{
		"echasnovski/mini.base16",
		lazy = true,
		version = pins.mini_base16.version,
	},
}
