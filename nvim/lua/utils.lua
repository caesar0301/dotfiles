-- Utility functions for Neovim configuration
-- Functions that don't depend on specific plugins

---Safely require a module with error handling
---@param mod string Module name to require
---@return table|nil Module if successful, nil if failed
local function safe_require(mod)
	local ok, m = pcall(require, mod)
	if not ok then
		vim.notify("Missing dependency: " .. mod, vim.log.levels.ERROR)
		return nil
	end
	return m
end

---Get environment variable with default value
---@param key string Environment variable name
---@param default string Default value if environment variable is not set
---@return string Value of environment variable or default
local function get_env(key, default)
	local value = os.getenv(key)
	return value or default
end

---Safely execute a system command
---@param cmd string Command to execute
---@param default string Default value if command fails
---@return string Command output or default value
local function safe_system(cmd, default)
	local ok, result = pcall(vim.fn.system, cmd)
	if ok and result and result ~= "" then
		return vim.fn.trim(result)
	end
	return default
end

---Create keymap options with description
---@param desc string Description for the keymap
---@return table Options table for keymap
local function opt_s(desc)
	return { desc = desc }
end

---Check if running in specific environment
---@param env_name string Environment variable name to check
---@return boolean True if environment variable is set
local function is_env_set(env_name)
	return os.getenv(env_name) ~= nil
end

---Check if running in GUI mode
---@return boolean True if running in GUI mode
local function is_gui_running()
	return vim.fn.has("gui_running") == 1
end

---Check if running in specific terminal
---@param term_name string Terminal name to check
---@return boolean True if running in specified terminal
local function is_terminal(term_name)
	return vim.env.COLORTERM == term_name
end

---Safely set colorscheme with fallback
---@param primary string Primary colorscheme to try
---@param fallback string Fallback colorscheme if primary fails
local function safe_colorscheme(primary, fallback)
	local status = pcall(vim.cmd, "colorscheme " .. primary)
	if not status then
		vim.cmd("colorscheme " .. fallback)
	end
end

---Safely create a user command
---@param name string Command name
---@param command string|function Command to execute
---@param opts table Command options
local function safe_user_command(name, command, opts)
	opts = opts or {}
	local status = pcall(vim.api.nvim_create_user_command, name, command, opts)
	if not status then
		vim.notify("Failed to create user command: " .. name, vim.log.levels.WARN)
	end
end

---Safely execute a vim command
---@param cmd string Vim command to execute
---@return boolean Success status
local function safe_cmd(cmd)
	local status = pcall(vim.cmd, cmd)
	if not status then
		vim.notify("Failed to execute command: " .. cmd, vim.log.levels.WARN)
	end
	return status
end

---Get Java binary path from environment variables
---@return string Path to Java binary
local function get_java_bin()
	local jdkhome = os.getenv("JAVA_HOME_4GJF")
	if jdkhome == nil then
		jdkhome = os.getenv("JAVA_HOME")
	end
	if jdkhome == nil then
		return "java"
	else
		return jdkhome .. "/bin/java"
	end
end

---Get Java binary path for JDTLS
---@return string Path to Java binary
local function get_java_binary()
	local jdkhome = os.getenv("JAVA_HOME_4JDTLS")
	if not jdkhome then
		jdkhome = os.getenv("JAVA_HOME")
	end
	if jdkhome then
		return jdkhome .. "/bin/java"
	end
	return "/usr/local/bin/java"
end

---Get Python path with fallback priority
---@return string Path to Python executable
local function get_python_path()
	-- 1. Check local .venv
	local venv_path = vim.fn.getcwd() .. "/.venv/bin/python"
	if vim.fn.executable(venv_path) == 1 then
		return venv_path
	end
	-- 2. Check pyenv version
	local pyenv_path = vim.fn.trim(vim.fn.system("pyenv which python 2>/dev/null"))
	if vim.fn.executable(pyenv_path) == 1 then
		return pyenv_path
	end
	-- 3. Fallback to system python
	if vim.fn.executable("/usr/bin/python3") == 1 then
		return "/usr/bin/python3"
	elseif vim.fn.executable("python3") == 1 then
		return "python3"
	else
		return "python"
	end
end

---Get JDTLS home directory
---@return string Path to JDTLS installation
local function get_jdtls_home()
	local home = os.getenv("HOME")
	local jdtls_home = os.getenv("JDTLS_HOME")
	if jdtls_home == nil or jdtls_home == "" then
		jdtls_home = home .. "/.local/share/jdt-language-server"
	end
	return jdtls_home
end

return {
	safe_require = safe_require,
	get_env = get_env,
	safe_system = safe_system,
	opt_s = opt_s,
	is_env_set = is_env_set,
	is_gui_running = is_gui_running,
	is_terminal = is_terminal,
	safe_colorscheme = safe_colorscheme,
	safe_user_command = safe_user_command,
	safe_cmd = safe_cmd,
	get_java_bin = get_java_bin,
	get_java_binary = get_java_binary,
	get_python_path = get_python_path,
	get_jdtls_home = get_jdtls_home,
}
