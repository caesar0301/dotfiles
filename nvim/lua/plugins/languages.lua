-- Language-Specific Support Plugins
return {
	-- Code style formatter
	{
		"stevearc/conform.nvim",
		event = "VimEnter",
		config = function()
			-- Load configuration from plugin/formatter.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/formatter.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end
			-- Create keymap after commands are created
			vim.keymap.set("n", "<leader>af", "<cmd>Format<cr>", { desc = "Format code" })
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
			-- Console settings
			vim.g.R_auto_start = 1
			vim.g.Rout_more_colors = 1
			vim.g.R_rconsole_width = 0
			vim.g.R_rconsole_height = 15
			-- Object browser settings
			vim.g.R_objbr_auto_start = 0
			vim.g.R_objbr_place = "script,right"
			-- Show data.frames elements
			vim.g.R_objbr_opendf = 1
			-- Show lists elements
			vim.g.R_objbr_openlist = 0
			-- Show hidden objects
			vim.g.R_objbr_allnames = 0
			vim.g.R_objbr_h = 10
			vim.g.R_objbr_w = 30
			-- Docs settings, mapped to <leader>rh
			vim.g.R_nvimpager = "vertical"
			-- Code sourcing settings
			vim.g.R_paragraph_begin = 0
			vim.g.R_parenblock = 1
			vim.g.R_clear_line = 1
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
			-- Vimtex settings
			vim.g.vimtex_compiler_method = "latexmk"

			if _G.IS_MAC then
				vim.g.vimtex_view_method = "skim"
			elseif _G.IS_LINUX then
				vim.g.vimtex_view_method = "zathura"
			end

			vim.g.vimtex_quickfix_mode = 2
			vim.g.vimtex_quickfix_autoclose_after_keystrokes = 1
			vim.g.vimtex_quickfix_open_on_warning = 0
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
