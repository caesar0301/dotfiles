-- Optimized Lazy.nvim Configuration
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim with optimized configuration
require("lazy").setup("plugins", {
	-- Lazy.nvim configuration options
	defaults = {
		lazy = true, -- Enable lazy loading by default for better performance
		version = false, -- Try installing the latest stable version for plugins that support semver
	},

	install = {
		missing = true, -- install missing plugins on startup
		colorscheme = { "codedark", "habamax" }, -- try to load one of these colorschemes when starting an installation during startup
	},

	checker = {
		enabled = true, -- automatically check for plugin updates
		notify = false, -- get a notification when new updates are found
		frequency = 3600, -- check for updates every hour
	},

	change_detection = {
		enabled = true,
		notify = false, -- get a notification when changes are found
	},

	ui = {
		size = { width = 0.8, height = 0.8 },
		wrap = true, -- wrap the lines in the ui
		border = "rounded",
		backdrop = 60,
		title = "Lazy Plugin Manager",
		title_pos = "center",
		pills = true, -- show pills in the ui
		icons = {
			cmd = " ",
			config = "",
			event = "",
			ft = " ",
			init = " ",
			import = " ",
			keys = " ",
			lazy = "󰒲 ",
			loaded = "●",
			not_loaded = "○",
			plugin = " ",
			runtime = " ",
			require = "󰢱 ",
			source = " ",
			start = "",
			task = "✔ ",
			list = {
				"●",
				"➜",
				"★",
				"‒",
			},
		},
	},

	performance = {
		cache = {
			enabled = true,
		},
		reset_packpath = true, -- reset the package path to improve startup time
		rtp = {
			reset = true, -- reset the runtime path to improve startup time
			paths = {}, -- add any custom paths here that you want to includes in the rtp
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},

	-- Development options
	dev = {
		path = "~/projects", -- directory where you store your local plugin projects
		patterns = {}, -- For example {"folke"}
		fallback = false, -- Fallback to git when local plugin doesn't exist
	},

	-- Profiling options
	profiling = {
		loader = false,
		require = false,
	},
})
