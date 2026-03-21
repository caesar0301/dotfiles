-- Nvim interface to configure tree-sitter and syntax highlighting
-- Uses modern nvim-treesitter API (main branch, incompatible rewrite)
-- NOTE: nvim-treesitter-refactor is deprecated and incompatible with modern nvim-treesitter
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false, -- Load immediately - core functionality
	build = ":TSUpdate",
	config = function()
		-- Install parsers asynchronously using the modern API
		require("nvim-treesitter.install").ensure_installed({
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
			"bash", -- Includes sh and zsh support
		})

		-- Enable treesitter highlighting for all filetypes (except shell scripts)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function()
				local ft = vim.bo.filetype

				-- Disable treesitter for shell scripts due to performance issues
				if ft == "bash" or ft == "sh" or ft == "zsh" then
					return
				end

				-- Safely start treesitter with error handling
				pcall(vim.treesitter.start)
			end,
		})

		-- Enable treesitter-based folding for supported filetypes
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"lua",
				"vim",
				"python",
				"go",
				"java",
				"markdown",
				"json",
				"c",
				"cpp",
				"rust",
				"javascript",
				"typescript",
			},
			callback = function()
				vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.wo[0][0].foldmethod = "expr"
				vim.wo[0][0].foldlevel = 99 -- Start with all folds open
			end,
		})
	end,
}
