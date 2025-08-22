vim.cmd([[packadd packer.nvim]])

local packer = require("packer")

packer.init({
	max_jobs = 10, -- Limit to 10 concurrent jobs
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	-- Comment out with gc/gcc/gcap
	use("tpope/vim-commentary")

	-- Code style formatter
	use("mhartington/formatter.nvim")

	---------------
	-- UI Interface
	---------------

	-- Themes
	use("tomasiser/vim-code-dark")

	-- Tabline with auto-sizing, clickable tabs, icons, highlighting etc.
	use({
		"romgrk/barbar.nvim",
		requires = {
			{ "nvim-tree/nvim-web-devicons" },
			{ "lewis6991/gitsigns.nvim" },
		},
	})

	-- Configure neovim statusline
	use({
		"nvim-lualine/lualine.nvim",
		requires = {
			{ "nvim-tree/nvim-web-devicons" },
			{ "nvim-lua/lsp-status.nvim" },
		},
	})

	-- Folder and file tree view
	use({
		"nvim-tree/nvim-tree.lua",
		requires = {
			{ "nvim-tree/nvim-web-devicons" },
			{ "antosha417/nvim-lsp-file-operations" },
			{ "echasnovski/mini.base16" },
		},
	})

	-- Displays tags in a window, ordered by scope
	use("preservim/tagbar")

	-- shows the context of the currently visible buffer contents
	use({
		"wellle/context.vim",
	})

	-- displays a popup with possible keybindings of the command you started typing
	use({
		"folke/which-key.nvim",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup({})
		end,
	})

	-- easily manage multiple terminal windows
	use({
		"akinsho/toggleterm.nvim",
		tag = "v2.13.1",
		config = function()
			require("toggleterm").setup()
		end,
	})

	-------------------
	-- Language Servers
	-------------------

	-- Quickstart configs for Nvim LSP
	use("neovim/nvim-lspconfig")

	-- Previewing native LSP's goto definition etc. in floating window
	use({
		"rmagatti/goto-preview",
		requires = {
			{ "rmagatti/logger.nvim" },
		},
		config = function()
			require("goto-preview").setup()
		end,
	})

	-- Code completion for Nvim LSP
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			{ "neovim/nvim-lspconfig" },
			{ "hrsh7th/cmp-nvim-lsp", branch = "main" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-cmdline" },
			{ "L3MON4D3/LuaSnip" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "lukas-reineke/cmp-under-comparator" },
		},
	})

	-- vscode-like pictograms for neovim LSP completion items
	use({
		"onsails/lspkind-nvim",
		config = function()
			require("lspkind").init({
				preset = "codicons",
			})
		end,
	})

	-- Debug Adapter Protocol client implementation for Neovim
	use("mfussenegger/nvim-dap")

	---------------------
	-- Search Enhancement
	---------------------

	-- Improved fzf.vim written in lua
	use({
		"ibhagwan/fzf-lua",
		requires = {
			{ "nvim-tree/nvim-web-devicons" },
			{ "junegunn/fzf", run = ":call fzf#install()" },
		},
	})

	-- Highly extendable fuzzy finder over file and symbols
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "BurntSushi/ripgrep" },
			{ "nvim-telescope/telescope-fzf-native.nvim" },
			{ "sharkdp/fd" },
			{ "nvim-treesitter/nvim-treesitter" },
			{ "nvim-tree/nvim-web-devicons" },
		},
	})

	-- Better quickfix window in Neovim, polish old quickfix window
	use({
		"kevinhwang91/nvim-bqf",
		requires = {
			{ "nvim-treesitter/nvim-treesitter" },
		},
	})

	------------------
	-- Git Integration
	------------------

	-- Show git diff markers in the sign column
	use("airblade/vim-gitgutter")

	-- Generating .gitignore files
	use({
		"wintermute-cell/gitignore.nvim",
		requires = {
			"nvim-telescope/telescope.nvim", -- optional: for multi-select
		},
	})

	-----------------------------
	-- Syntax Highlight (General)
	-----------------------------

	-- Nvim interface to configure tree-sitter and syntax highlighting
	use("nvim-treesitter/nvim-treesitter")
	use("nvim-treesitter/nvim-treesitter-refactor")

	-- Highlight arguments' definitions and usages, using Treesitter
	use({
		"m-demare/hlargs.nvim",
		config = function()
			require("hlargs").setup()
		end,
		requires = {
			{ "nvim-treesitter/nvim-treesitter" },
		},
	})

	-- Autopairs supporting multiple characters
	use("windwp/nvim-autopairs")

	-- Add/change/delete surrounding delimiter pairs with ease
	use({
		"kylechui/nvim-surround",
		tag = "v3.1.3",
		config = function()
			require("nvim-surround").setup({})
		end,
	})

	-------------------
	-- Language Support
	-------------------

	-- CMake integration comparable to vscode-cmake-tools
	use({
		"Civitasv/cmake-tools.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
		},
		config = function()
			require("cmake-tools").setup({})
		end,
	})

	-- Markdown support
	use("plasticboy/vim-markdown")
	use("MeanderingProgrammer/render-markdown.nvim")

	-- Markdown preview in modern browser
	use({
		"iamcco/markdown-preview.nvim",
		run = function()
			vim.fn["mkdp#util#install"]()
		end,
	})

	-- EditorConfig synatx highlighting
	use("editorconfig/editorconfig-vim")

	-- Javascript indentation and syntax support
	use("pangloss/vim-javascript")

	-- Rlang support for vim
	use({
		"jalvesaq/Nvim-R",
		requires = {
			{ "jalvesaq/cmp-nvim-r" },
			{ "jalvesaq/colorout" },
			-- {"jalvesaq/zotcite"},
			-- {"jalvesaq/cmp-zotcite"}
		},
	})

	-- LaTeX synatx highlighting
	use("lervag/vimtex")

	-- Rust support (conditionally loaded based on system compatibility)
	if SUPPORTS_MODERN_PLUGINS then
		use("rust-lang/rust.vim")
	else
		-- Fallback message for unsupported systems
		vim.defer_fn(function()
			if IS_MAC then
				vim.notify("Rust plugin disabled: Not supported on macOS", vim.log.levels.WARN)
			else
				vim.notify("Rust plugin disabled: Kernel version " .. KERNEL_VERSION .. " < 5.0", vim.log.levels.WARN)
			end
		end, 100)
	end

	-- Haskell synatx highlighting
	use("neovimhaskell/haskell-vim")

	-- Python static syntax and style checker using Flake8
	use("nvie/vim-flake8")

	-- Ruby synatx highlighting
	use("vim-ruby/vim-ruby")

	-- CSV filetype integration
	use("chrisbra/csv.vim")
	use("godlygeek/tabular")

	-- Common Lisp dev environment for Vim (alternative to Conjure)
	use({
		"vlime/vlime",
		rtp = "vim/",
		requires = {
			{ "HiPhish/nvim-cmp-vlime" },
			{ "kovisoft/paredit" },
		},
	})
end)
