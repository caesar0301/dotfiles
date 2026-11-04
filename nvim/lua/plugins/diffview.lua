-- Diff and branch diff viewer: review all changed files for any git rev
local pins = require("plugin-pins")

return {
	"sindrets/diffview.nvim",
	-- Upstream publishes no release tags; track main (see plugin-pins.lua).
	version = pins.no_tags.version,
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
		"DiffviewFileHistory",
	},
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "[diffview] Working tree changes" },
		{
			"<leader>gb",
			function()
				local rev = vim.trim(vim.fn.input("Diff rev (e.g. origin/main...HEAD): "))
				if rev ~= "" then
					vim.cmd({ cmd = "DiffviewOpen", args = vim.split(rev, "%s+") })
				end
			end,
			desc = "[diffview] Diff against a branch / commit",
		},
		{
			"<leader>gh",
			function()
				vim.cmd({ cmd = "DiffviewFileHistory", args = { vim.fn.expand("%") } })
			end,
			desc = "[diffview] Current file history",
		},
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "[diffview] Branch history" },
		{ "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "[diffview] Close diff view" },
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("diffview").setup({
			enhanced_diff_hl = true,
			use_icons = true,
		})
	end,
}
