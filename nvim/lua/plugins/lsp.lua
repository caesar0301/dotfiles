-- Language Server Protocol Plugins
return {
	-- Quickstart configs for Nvim LSP
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-lua/lsp-status.nvim",
			"rmagatti/goto-preview",
		},
		config = function()
			-- Load configuration from plugin/lspconfig.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/lspconfig.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end
		end,
	},

	-- LSP status integration
	{
		"nvim-lua/lsp-status.nvim",
		lazy = true,
	},

	-- Previewing native LSP's goto definition etc. in floating window
	{
		"rmagatti/goto-preview",
		lazy = true,
		dependencies = {
			"rmagatti/logger.nvim",
		},
	},

	-- Logger for goto-preview
	{
		"rmagatti/logger.nvim",
		lazy = true,
	},

	-- Code completion for Nvim LSP
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"neovim/nvim-lspconfig",
			{ "hrsh7th/cmp-nvim-lsp", branch = "main" },
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"lukas-reineke/cmp-under-comparator",
		},
		config = function()
			-- Load configuration from plugin/nvim-cmp.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/nvim-cmp.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end
		end,
	},

	-- CMP sources
	{ "hrsh7th/cmp-nvim-lsp", lazy = true },
	{ "hrsh7th/cmp-buffer", lazy = true },
	{ "hrsh7th/cmp-path", lazy = true },
	{ "hrsh7th/cmp-cmdline", lazy = true },
	{ "saadparwaiz1/cmp_luasnip", lazy = true },
	{ "lukas-reineke/cmp-under-comparator", lazy = true },

	-- Snippet engine
	{
		"L3MON4D3/LuaSnip",
		lazy = true,
		build = "make install_jsregexp",
	},

	-- vscode-like pictograms for neovim LSP completion items
	{
		"onsails/lspkind-nvim",
		lazy = true,
		config = function()
			-- Load configuration from plugin/lspkind.lua
			local config_path = vim.fn.stdpath("config") .. "/plugin/lspkind.lua"
			if vim.fn.filereadable(config_path) == 1 then
				dofile(config_path)
			end
		end,
	},

	-- Debug Adapter Protocol client implementation for Neovim
	{
		"mfussenegger/nvim-dap",
		cmd = { "DapToggleBreakpoint", "DapContinue" },
		keys = {
			{ "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle breakpoint" },
			{ "<leader>dc", "<cmd>DapContinue<cr>", desc = "Continue debugging" },
		},
	},
}
