-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- Quit as last buffer, fix issue by @ppwwyyxx
-- https://github.com/nvim-tree/nvim-tree.lua/issues/1368#issuecomment-1512248492
vim.api.nvim_create_autocmd("QuitPre", {
	callback = function()
		local invalid_win = {}
		local wins = vim.api.nvim_list_wins()
		for _, w in ipairs(wins) do
			local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
			if bufname:match("NvimTree_") ~= nil then
				table.insert(invalid_win, w)
			end
		end
		if #invalid_win == #wins - 1 then
			-- Should quit, so we close all invalid windows.
			for _, w in ipairs(invalid_win) do
				vim.api.nvim_win_close(w, true)
			end
		end
	end,
})

local function my_on_attach(bufnr)
	local api = require("nvim-tree.api")
	local opts = { desc = "[nvim-tree] Help" }
	opts.nowait = true
	opts.buffer = bufnr
	-- default mappings
	api.config.mappings.default_on_attach(bufnr)
	vim.keymap.set("n", "?", api.tree.toggle_help, opts)
end

-- pass to setup along with your other options
require("nvim-tree").setup({
	on_attach = my_on_attach,
	sort_by = "case_sensitive",
	view = {
		width = 35,
	},
	renderer = {
		group_empty = true,
		icons = {
			git_placement = "after",
		},
	},
	update_focused_file = {
		enable = true,
		update_root = false,
		ignore_list = {},
	},
	filters = {
		dotfiles = false,
	},
})

-- Keymaps for nvim-tree
vim.keymap.set("n", "<F8>", "<cmd>:NvimTreeFindFileToggle!<cr>", { desc = "[nvim-tree] Toggle find file" })
vim.keymap.set("n", "<leader>N", "<cmd>:NvimTreeFindFileToggle!<cr>", { desc = "[nvim-tree] Toggle find file" })
vim.keymap.set("n", "<leader>nn", "<cmd>:NvimTreeFindFileToggle!<cr>", { desc = "[nvim-tree] Toggle find file" })
