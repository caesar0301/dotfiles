-- Nvim interface to configure tree-sitter and syntax highlighting
return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPost", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-refactor",
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"lua",
				"luadoc",
				"vim",
				"vimdoc",
				"python",
				"go",
				"java",
				"markdown",
				"markdown_inline",
				"yaml",
			},
			autotag = {
				enable = true,
			},
			-- Install languages synchronously (only applies to `ensure_installed`)
			sync_install = false,
			-- Automatically install missing parsers when entering buffer
			auto_install = true,
			ignore_install = {},
			highlight = {
				enable = true,
				disable = { "bash" },
				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = false,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "gnn",
					scope_incremental = "grc",
					node_incremental = "+",
					node_decremental = "_",
				},
			},
			-- requires nvim-treesitter-refactor
			refactor = {
				highlight_definitions = {
					enable = true,
					-- Set to false if you have an `updatetime` of ~100.
					clear_on_cursor_move = true,
				},
				highlight_current_scope = {
					enable = false,
				},
				smart_rename = {
					enable = true,
					-- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
					keymaps = {
						smart_rename = "grr",
					},
				},
			},
		})
	end,
}
