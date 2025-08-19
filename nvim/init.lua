-------------------------------------------------------------
-- Maintainer:
--       Xiaming Chen - @caesar0301
--
-- Prerequisites:
--       packer: https://github.com/wbthomason/packer.nvim
--       neovim: https://neovim.io/
--
-- Usage: :PackerInstall
-------------------------------------------------------------

-- Setup globals that I expect to be always available.
-- Load core modules from lua directory in correct dependency order
require("utils") -- Utility functions (no dependencies)
require("globals") -- Global variables and system detection (must come first)
require("packer-config") -- Plugin manager (depends on globals)
require("autocmds") -- Auto-commands (depends on globals)

-- Setup system compatibility checking (depends on globals)
require("system-check").setup()

-- Load preference settings (depends on utils)
require("preference")

-- Load keymaps (depends on utils)
require("keymaps")

-- Load all user preferences
local paths = vim.split(vim.fn.glob("~/.config/nvim/vimscripts/**/*.vim"), "\n")
for i, file in pairs(paths) do
	vim.cmd("source " .. file)
end
