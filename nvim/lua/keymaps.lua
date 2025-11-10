-------------------------------------------------------------------------------
-- Keymaps configuration for Neovim
-- Organized by functional group, with clear comments and section headers
-------------------------------------------------------------------------------

-- =====================
-- 1. Editing
-- =====================
-- Save/Quit commands (capitalized variants for convenience)
local utils = require("utils")
utils.safe_user_command("W", "wa", { desc = "Save all buffers" })
utils.safe_user_command("Q", "qa", { desc = "Quit all buffers" })
utils.safe_user_command("Wq", "waq", { desc = "Save all buffers and quit current" })
utils.safe_user_command("WQ", "waqa", { desc = "Save and quit all buffers" })
utils.safe_user_command("Qa", "qa", { desc = "Quit all buffers" })

vim.keymap.set({ "n", "v" }, "<leader>W", "<cmd>wa<cr>", { desc = "Save all buffers" })
vim.keymap.set({ "n", "v" }, "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all buffers" })

-- Save current buffer
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save current buffer" })
vim.keymap.set("i", "<C-s>", "<ESC>:w<CR>l", { desc = "Save current buffer" })
vim.keymap.set("v", "<C-s>", "<ESC>:w<CR>", { desc = "Save current buffer" })

-- Disable Join to avoid accidental trigger
vim.keymap.set({ "n", "v" }, "J", "<Nop>", { silent = true, desc = "Disable [J]oin action" })

-- Remap 0 to first non-blank character
vim.keymap.set("", "0", "^", { desc = "Goto first non-blank char" })

-- Goto line head and tail
vim.keymap.set("n", "<C-a>", "<ESC>^", { desc = "Goto line head" })
vim.keymap.set("i", "<C-a>", "<ESC>I", { desc = "Goto line head" })
vim.keymap.set("n", "<C-e>", "<ESC>$", { desc = "Goto line tail" })
vim.keymap.set("i", "<C-e>", "<ESC>A", { desc = "Goto line tail" })

-- Move line in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected downwards" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected upwards" })

-- Do not yank empty lines with dd
vim.keymap.set("n", "dd", function()
	if vim.api.nvim_get_current_line():match("^%s*$") then
		return '"_dd'
	else
		return "dd"
	end
end, { expr = true })

-- Delete a word using Ctrl+Backspace
vim.keymap.set("i", "<C-BS>", "<C-w>")
vim.keymap.set("c", "<C-BS>", "<C-w>")

-- Pressing ,ss will toggle and untoggle spell checking
vim.keymap.set("", "<leader>ss", "<cmd>setlocal spell!<cr>", { desc = "Toggle spell checking" })

-- =====================
-- 2. View, Window, and Tabs
-- =====================
-- Move between windows (split navigation)
vim.keymap.set("", "<C-j>", "<C-W>j")
vim.keymap.set("", "<C-k>", "<C-W>k")
vim.keymap.set("", "<C-h>", "<C-W>h")
vim.keymap.set("", "<C-l>", "<C-W>l")

-- Change working directory to current buffer's directory
vim.keymap.set("", "<leader>cd", "<cmd>cd %:p:h<cr>:pwd<cr>", { desc = "CWD to dir of current buffer" })

-- Command-line mode shortcuts
-- Helper function to get current file directory
local function current_file_dir(cmd)
	return cmd .. " " .. vim.fn.expand("%:p:h") .. "/"
end

-- Helper function to delete till slash in command line
local function delete_till_slash()
	local cmd = vim.fn.getcmdline()
	local cmd_edited = vim.fn.substitute(cmd, "\\(.*[/]\\).*", "\\1", "")

	if cmd == cmd_edited then
		cmd_edited = vim.fn.substitute(cmd, "\\(.*[/]\\).*/", "\\1", "")
	end

	return cmd_edited
end

-- Command-line abbreviations for directory navigation
vim.keymap.set("c", "$h", "e ~/", { desc = "Edit from home directory" })
vim.keymap.set("c", "$c", function()
	return current_file_dir("e")
end, { expr = true, desc = "Edit from current file directory" })
vim.keymap.set("c", "$q", function()
	return delete_till_slash()
end, { expr = true, desc = "Delete till last slash" })

-- Bash-like keys for the command line
vim.keymap.set("c", "<C-A>", "<Home>", { desc = "Go to start of line" })
vim.keymap.set("c", "<C-E>", "<End>", { desc = "Go to end of line" })
vim.keymap.set("c", "<C-K>", "<C-U>", { desc = "Delete to start of line" })
vim.keymap.set("c", "<C-P>", "<Up>", { desc = "Previous command" })
vim.keymap.set("c", "<C-N>", "<Down>", { desc = "Next command" })

-- Map ½ to $ (useful on some keyboards)
vim.keymap.set({ "n", "i", "c" }, "½", "$", { desc = "Map ½ to $" })

-- =====================
-- 3. Search and Replace
-- =====================
-- Map <leader> to / (search) and Ctrl-<leader> to ? (backwards search)
vim.keymap.set("n", "<space>", "/", { desc = "Search" })
vim.keymap.set("n", "<C-space>", "?", { desc = "Backwards search" })

-- Visual mode: search for selected text with * and #
vim.keymap.set("v", "*", function()
	-- Save current register
	local saved_reg = vim.fn.getreg('"')
	-- Yank visual selection
	vim.cmd("normal! vgvy")
	-- Get pattern and escape special characters
	local pattern = vim.fn.escape(vim.fn.getreg('"'), "\\/.*'$^~[]")
	pattern = vim.fn.substitute(pattern, "\n$", "", "")
	-- Set search register and perform search
	vim.fn.setreg("/", pattern)
	vim.fn.setreg('"', saved_reg)
	-- Execute forward search
	vim.fn.feedkeys("/" .. vim.fn.getreg("/") .. "\r", "n")
end, { silent = true, desc = "Search forward for visual selection" })

vim.keymap.set("v", "#", function()
	-- Save current register
	local saved_reg = vim.fn.getreg('"')
	-- Yank visual selection
	vim.cmd("normal! vgvy")
	-- Get pattern and escape special characters
	local pattern = vim.fn.escape(vim.fn.getreg('"'), "\\/.*'$^~[]")
	pattern = vim.fn.substitute(pattern, "\n$", "", "")
	-- Set search register and perform search
	vim.fn.setreg("/", pattern)
	vim.fn.setreg('"', saved_reg)
	-- Execute backward search
	vim.fn.feedkeys("?" .. vim.fn.getreg("/") .. "\r", "n")
end, { silent = true, desc = "Search backward for visual selection" })

-- Find and replace current word under cursor (case sensitive)
vim.keymap.set(
	"n",
	"<leader>rw",
	":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
	{ desc = "Replace current word (case sensitive)" }
)
vim.keymap.set(
	"v",
	"<leader>rw",
	":s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
	{ desc = "Replace current word (case sensitive)" }
)
vim.keymap.set({ "n", "v" }, "<leader>R", "<leader>rw", { remap = true })

-- Find and replace with cdo (quickfix)
local utils = require("utils")
utils.safe_user_command("FindAndReplace", function(opts)
	vim.api.nvim_command(string.format("cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
	vim.api.nvim_command("cfdo update")
end, { nargs = "*" })
vim.keymap.set("n", "<leader>fr", ":FindAndReplace ", { desc = "[QuickFix] Find and replace" })

-- clear highlight of search, messages, floating windows
vim.keymap.set({ "n", "i" }, "<Esc>", function()
	vim.cmd([[nohl]]) -- clear highlight of search
	vim.cmd([[stopinsert]]) -- clear messages (the line below statusline)
	for _, win in ipairs(vim.api.nvim_list_wins()) do -- clear all floating windows
		if vim.api.nvim_win_get_config(win).relative == "win" then
			vim.api.nvim_win_close(win, false)
		end
	end
end, { desc = "Clear highlight of search, messages, floating windows" })

-- =====================
-- 4. Miscellaneous
-- =====================

-- Insert current date and time (ISO 8601 format with timezone)
vim.keymap.set("n", "<leader>ts", "a<C-R>=strftime('%Y-%m-%dT%H:%M:%S%z')<CR><Esc>", { desc = "Insert timestamp" })
vim.keymap.set("i", "<leader>ts", "<C-R>=strftime('%Y-%m-%dT%H:%M:%S%z')<CR>", { desc = "Insert timestamp" })

-- Compile and run (user-defined CompileRun function)
vim.keymap.set("n", "<F5>", "<cmd>call CompileRun()<CR>", { desc = "Compile and Run" })
vim.keymap.set("i", "<F5>", "<Esc><cmd>call CompileRun()<CR>", { desc = "Compile and Run" })
vim.keymap.set("v", "<F5>", "<Esc><cmd>call CompileRun()<CR>", { desc = "Compile and Run" })
