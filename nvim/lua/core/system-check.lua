-- System compatibility check for Neovim plugins
-- This module provides commands and utilities to check system compatibility

local M = {}

-- Display detailed system compatibility information
function M.show_compatibility_info()
	local lines = {
		"=== Neovim System Compatibility Report ===",
		"",
		"System Information:",
		string.format("  Operating System: %s", OS),
		string.format("  Architecture: %s", vim.loop.os_uname().machine),
		string.format("  Kernel Version: %s", KERNEL_VERSION),
		"",
		"Platform Detection:",
		string.format("  Linux: %s", tostring(IS_LINUX)),
		string.format("  macOS: %s", tostring(IS_MAC)),
		string.format("  Windows: %s", tostring(IS_WINDOWS)),
		string.format("  WSL: %s", tostring(IS_WSL)),
		"",
		"Plugin Compatibility:",
		string.format("  Modern Plugin Support: %s", tostring(SUPPORTS_MODERN_PLUGINS)),
		string.format("  Rust Plugin Support: %s", tostring(SUPPORTS_RUST_PLUGINS)),
		"",
		"Plugin Status:",
	}

	-- Check specific plugin availability
	local plugins_to_check = {
		{ name = "avante.nvim", supported = SUPPORTS_MODERN_PLUGINS, reason = "Requires kernel >= 5.0" },
		{ name = "rust.vim", supported = SUPPORTS_RUST_PLUGINS, reason = "Requires Linux with kernel >= 5.0" },
	}

	for _, plugin in ipairs(plugins_to_check) do
		local status = plugin.supported and "✓ Available" or "✗ Disabled"
		local reason = plugin.supported and "" or string.format(" (%s)", plugin.reason)
		table.insert(lines, string.format("  %s: %s%s", plugin.name, status, reason))
	end

	table.insert(lines, "")
	table.insert(lines, "Neovim Version: " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch)
	table.insert(lines, "")

	if not SUPPORTS_MODERN_PLUGINS then
		table.insert(lines, "⚠️  Warning: Some modern plugins are disabled due to system compatibility.")
		table.insert(lines, "   Consider upgrading your kernel to version 5.0 or higher for full functionality.")
	else
		table.insert(lines, "✅ All modern plugins are supported on this system.")
	end

	-- Display in a new buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "filetype", "text")
	vim.api.nvim_buf_set_name(buf, "System Compatibility Report")

	-- Open in a split window
	vim.cmd("split")
	vim.api.nvim_win_set_buf(0, buf)
	vim.api.nvim_win_set_height(0, math.min(#lines + 2, 20))

	-- Make buffer read-only
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "readonly", true)

	-- Add keybinding to close
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
end

-- Check if a specific plugin should be loaded
function M.should_load_plugin(plugin_name)
	local plugin_requirements = {
		["avante.nvim"] = function()
			return SUPPORTS_MODERN_PLUGINS
		end,
		["rust.vim"] = function()
			return SUPPORTS_RUST_PLUGINS
		end,
	}

	local check_func = plugin_requirements[plugin_name]
	if check_func then
		return check_func()
	end

	-- Default: allow loading if no specific requirements
	return true
end

-- Setup user commands
function M.setup()
	-- Create user command for compatibility check
	vim.api.nvim_create_user_command("SystemCheck", function()
		M.show_compatibility_info()
	end, {
		desc = "Show system compatibility information for Neovim plugins",
	})

	-- Create user command to show system info (shorter version)
	vim.api.nvim_create_user_command("SystemInfo", function()
		show_system_info()
	end, {
		desc = "Show basic system information",
	})

	-- Add notification on startup if modern plugins are disabled
	if not SUPPORTS_MODERN_PLUGINS then
		vim.defer_fn(function()
			vim.notify(
				string.format(
					"Some plugins disabled due to kernel version %s < 5.0. Run :SystemCheck for details.",
					KERNEL_VERSION
				),
				vim.log.levels.WARN,
				{ title = "Plugin Compatibility" }
			)
		end, 2000) -- Delay to avoid startup noise
	end
end

return M