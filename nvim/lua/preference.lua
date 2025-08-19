-- =============================================================================
-- Preference Configuration for Neovim
-- Merged from multiple preference files for better organization
-- =============================================================================

-- =====================
-- 1. UI & Editing Preferences
-- =====================

-- Line Numbers
vim.opt.number = true

-- Indentation & Tabs
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smarttab = true -- Smart tab behavior
vim.opt.tabstop = 4 -- A tab is 4 spaces
vim.opt.shiftwidth = 2 -- Indent by 2 spaces
vim.opt.autoindent = true -- Auto indent new lines
vim.opt.smartindent = true -- Smart autoindenting

-- Line Wrapping & Text Width
vim.opt.wrap = true -- Wrap lines
vim.opt.linebreak = true -- Wrap at word boundaries
vim.opt.textwidth = 79 -- Linebreak at 79 chars
vim.opt.formatoptions:append("mM") -- Better CJK line wrapping

-- Cursor & Navigation
vim.opt.scrolloff = 7 -- Keep 7 lines above/below cursor
vim.opt.ruler = true -- Show cursor position
vim.opt.cmdheight = 1 -- Command bar height

-- Wildmenu & File Ignore
vim.opt.wildmenu = true
vim.opt.wildignore = { "*.o", "*~", "*.pyc" }
if vim.fn.has("win16") == 1 or vim.fn.has("win32") == 1 then
	vim.opt.wildignore:append({ ".git/*", ".hg/*", ".svn/*" })
else
	vim.opt.wildignore:append({ "*/.git/*", "*/.hg/*", "*/.svn/*", "*/.DS_Store" })
end

-- Buffer & Backspace Behavior
vim.opt.hidden = true -- Allow background buffers
vim.opt.backspace:append({ "eol", "start", "indent" })
vim.opt.whichwrap = vim.opt.whichwrap + "<,>,h,l"

-- Search
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.smartcase = true -- ...unless uppercase used

-- Highlight search results
vim.opt.hlsearch = true

-- Makes search act like search in modern browsers
vim.opt.incsearch = true

-- Don't redraw while executing macros (good performance config)
vim.opt.lazyredraw = true

-- For regular expressions turn magic on
vim.opt.magic = true

-- Show matching brackets when text indicator is over them
vim.opt.showmatch = true

-- How many tenths of a second to blink when matching brackets
vim.opt.matchtime = 2

-- No annoying sound on errors
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.tm = 500

-- =====================
-- 2. Environment & Terminal Detection
-- =====================

local utils = require("utils")

-- Enable 256 colors palette in Gnome Terminal
if utils.is_terminal("gnome-terminal") then
	vim.opt.termguicolors = true
end

-- Theme
vim.opt.background = "dark"
utils.safe_colorscheme("codedark", "elflord")

-- Set extra options when running in GUI mode
if utils.is_gui_running() then
	vim.opt.termguicolors = true
	-- vim.opt.guitablabel = "%M %t"
end

if utils.is_env_set("TMUX") then
	vim.opt.termguicolors = true
end

-- Set utf8 as standard encoding and en_US as the standard language
--vim.cmd("language en_US.UTF-8")
vim.opt.encoding = "utf8"

-- Use Unix as the standard file type
vim.opt.fileformats = { "unix", "dos", "mac" }

-- =====================
-- 3. Tabline & Buffer Behavior
-- =====================

-- Specify the behavior when switching between buffers
pcall(function()
	vim.opt.switchbuf:append("useopen", "usetab", "newtab")
	vim.opt.stal = 2
end)

-- =====================
-- 4. Neovide UI Settings
-- =====================

-- Neovide UI settings
vim.print(vim.g.neovide_version)
--vim.o.guifont = "Source Code Pro:h14"
vim.g.neovide_remember_window_size = true

-- animation
vim.g.neovide_scroll_animation_length = 0.1
vim.g.neovide_cursor_animation_length = 0.05
vim.g.neovide_cursor_trail_size = 0.5
vim.g.neovide_cursor_animate_command_line = false

-- =====================
-- 5. Editing & File Management
-- =====================

-- Delete trailing whitespace on save
function CleanExtraSpaces()
	local save_cursor = vim.fn.getpos(".")
	local old_query = vim.fn.getreg("/")
	vim.cmd([[silent! %s/\s\+$//e]])
	vim.fn.setpos(".", save_cursor)
	vim.fn.setreg("/", old_query)
end

utils.safe_cmd([[
  augroup CleanExtraSpaces
    autocmd!
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee,*.lisp lua CleanExtraSpaces()
  augroup END
]])

-- Turn on persistent undo
local status, result = pcall(function()
	vim.o.undodir = utils.get_env("VIM_UNDODIR", "/tmp/.vim_runtime/temp_dirs/undodir")
	vim.o.undofile = true
end)

-- =====================
-- 6. Miscellaneous Settings
-- =====================

-- Paste mode (conflicts with autopairs)
-- vim.opt.paste = true

-- vim copy to clipboard and via ssh
-- for nvim 0.10.0+, enable auto osc52. see :help clipboard-osc52
-- vim.opt.clipboard:append {"unnamed", "unnamedplus"}

function my_paste(reg)
	return function(lines)
		local content = vim.fn.getreg('"')
		return vim.split(content, "\n")
	end
end

if not utils.is_env_set("SSH_TTY") then
	vim.opt.clipboard:append("unnamedplus")
else
	vim.opt.clipboard:append("unnamedplus")
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = my_paste("+"),
			["*"] = my_paste("*"),
		},
	}
end

-- Sets how many lines of history VIM has to remember
vim.opt.history = 500

-- Turn backup off, since most stuff is in SVN, git etc. anyway...
vim.opt.backup = false
vim.opt.wb = false
vim.opt.swapfile = false

-- Enable spell checking, excluding Chinese char
vim.opt.spelllang = vim.opt.spelllang + "en_us" + "cjk"
vim.opt.spell = false

-- In case of invalid default Python3 version
local nvimpy = utils.get_env("NVIM_PYTHON3", "")
if nvimpy ~= "" then
	vim.g.python3_host_prog = nvimpy .. "/bin/python3"
end
