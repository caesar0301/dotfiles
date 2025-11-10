-- Generating .gitignore files
return {
	"wintermute-cell/gitignore.nvim",
	cmd = { "Gitignore" },
	dependencies = {
		"nvim-telescope/telescope.nvim", -- optional: for multi-select
	},
	config = function()
		-- Keymaps for gitignore
		vim.keymap.set("n", "<leader>gi", require("gitignore").generate, { desc = "Add gitignore" })
	end,
}
