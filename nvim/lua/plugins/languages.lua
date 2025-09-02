-- Language-Specific Support Plugins
return {
	-- Code style formatter
	{
		"mhartington/formatter.nvim",
		cmd = { "Format", "FormatWrite" },
		keys = {
			{ "<leader>f", "<cmd>Format<cr>", desc = "Format code" },
		},
		config = function()
			-- Load configuration from plugin/formatter.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/formatter.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end
		end,
	},

	-- CMake integration comparable to vscode-cmake-tools
	{
		"Civitasv/cmake-tools.nvim",
		ft = { "cmake", "cpp", "c" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("cmake-tools").setup({})
		end,
	},

	-- Markdown support
	{
		"plasticboy/vim-markdown",
		ft = "markdown",
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = "markdown",
	},

	-- Markdown preview in modern browser
	{
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
	},

	-- EditorConfig syntax highlighting
	{
		"editorconfig/editorconfig-vim",
		event = { "BufReadPre", "BufNewFile" },
	},

	-- Javascript indentation and syntax support
	{
		"pangloss/vim-javascript",
		ft = { "javascript", "javascriptreact" },
	},

	-- R language support for vim
	{
		"jalvesaq/Nvim-R",
		ft = { "r", "rmd", "rnoweb", "rhelp", "rrst" },
		dependencies = {
			"jalvesaq/cmp-nvim-r",
			"jalvesaq/colorout",
		},
		config = function()
			-- Load configuration from plugin/nvim-r.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/nvim-r.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end
		end,
	},

	-- R language dependencies
	{ "jalvesaq/cmp-nvim-r", lazy = true },
	{ "jalvesaq/colorout", lazy = true },

	-- LaTeX syntax highlighting
	{
		"lervag/vimtex",
		ft = { "tex", "latex" },
		config = function()
			-- Load configuration from plugin/vimtex.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/vimtex.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end
		end,
	},

	-- Rust support (conditionally loaded based on system compatibility)
	{
		"rust-lang/rust.vim",
		ft = "rust",
		cond = function()
			if not SUPPORTS_MODERN_PLUGINS then
				-- Show warning message when plugin is not loaded
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

	-- Haskell syntax highlighting
	{
		"neovimhaskell/haskell-vim",
		ft = "haskell",
	},

	-- Python static syntax and style checker using Flake8
	{
		"nvie/vim-flake8",
		ft = "python",
	},

	-- Ruby syntax highlighting
	{
		"vim-ruby/vim-ruby",
		ft = "ruby",
	},

	-- CSV filetype integration
	{
		"chrisbra/csv.vim",
		ft = "csv",
	},

	{
		"godlygeek/tabular",
		cmd = "Tabularize",
	},

	-- Common Lisp dev environment for Vim (alternative to Conjure)
	{
		"vlime/vlime",
		ft = { "lisp", "commonlisp" },
		init = function()
			vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/vlime/vim")
		end,
		dependencies = {
			"HiPhish/nvim-cmp-vlime",
			"kovisoft/paredit",
		},
	},

	-- Vlime dependencies
	{ "HiPhish/nvim-cmp-vlime", lazy = true },
	{ "kovisoft/paredit", lazy = true },
}
