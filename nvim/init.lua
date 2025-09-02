-------------------------------------------------------------
-- Maintainer:
--       Xiaming Chen - @caesar0301
--
-- Prerequisites:
--       lazy.nvim: https://github.com/folke/lazy.nvim
--       neovim: https://neovim.io/
--
-- Usage: Plugins auto-install on first startup
-------------------------------------------------------------

-- Setup globals that I expect to be always available.
-- Load core modules from lua directory in correct dependency order
require("utils") -- Utility functions (no dependencies)
require("globals") -- Global variables and system detection (must come first)
require("lazy-config-optimized") -- Plugin manager (depends on globals)
require("autocmds") -- Auto-commands (depends on globals)

-- Load preference settings (depends on utils)
require("preference")

-- Load keymaps (depends on utils)
require("keymaps")

-- Load all user preferences
local paths = vim.split(vim.fn.glob("~/.config/nvim/vimscripts/**/*.vim"), "\n")
for i, file in pairs(paths) do
	vim.cmd("source " .. file)
end
