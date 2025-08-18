local uname = vim.loop.os_uname()

-- System detection
_G.OS = uname.sysname
_G.IS_MAC = OS == "Darwin"
_G.IS_LINUX = OS == "Linux"
_G.IS_WINDOWS = OS:find("Windows") and true or false
_G.IS_WSL = (function()
	local output = vim.fn.systemlist("uname -r")
	local condition1 = IS_LINUX and uname.release:lower():find("microsoft") and true or false
	local condition2 = not (not string.find(output[1] or "", "WSL"))
	return condition1 or condition2
end)()

-- Kernel version detection for compatibility checks
_G.KERNEL_VERSION = (function()
	if not IS_LINUX then
		return "0.0.0"
	end
	
	local handle = io.popen("uname -r 2>/dev/null")
	if not handle then
		return "0.0.0"
	end
	
	local result = handle:read("*a")
	handle:close()
	
	if not result or result == "" then
		return "0.0.0"
	end
	
	-- Extract major.minor version (e.g., "5.15.0-91-generic" -> "5.15")
	local major, minor = result:match("^(%d+)%.(%d+)")
	if major and minor then
		return major .. "." .. minor
	else
		return "0.0.0"
	end
end)()

-- Kernel version comparison utility
_G.kernel_version_compare = function(version1, version2)
	-- Compare two version strings (e.g., "5.15" vs "5.0")
	-- Returns: 1 if version1 > version2, -1 if version1 < version2, 0 if equal
	local function parse_version(v)
		local major, minor = v:match("^(%d+)%.(%d+)")
		return tonumber(major) or 0, tonumber(minor) or 0
	end
	
	local maj1, min1 = parse_version(version1)
	local maj2, min2 = parse_version(version2)
	
	if maj1 > maj2 then
		return 1
	elseif maj1 < maj2 then
		return -1
	elseif min1 > min2 then
		return 1
	elseif min1 < min2 then
		return -1
	else
		return 0
	end
end

-- Check if kernel version meets minimum requirement
_G.kernel_meets_requirement = function(min_version)
	return kernel_version_compare(KERNEL_VERSION, min_version or "5.0") >= 0
end

-- Compatibility flags for plugin loading
_G.SUPPORTS_MODERN_PLUGINS = kernel_meets_requirement("5.0")
_G.SUPPORTS_RUST_PLUGINS = IS_LINUX and SUPPORTS_MODERN_PLUGINS

-- System information display
_G.show_system_info = function()
	local info = {
		"System Information:",
		"  OS: " .. OS,
		"  Linux: " .. tostring(IS_LINUX),
		"  macOS: " .. tostring(IS_MAC),
		"  Windows: " .. tostring(IS_WINDOWS),
		"  WSL: " .. tostring(IS_WSL),
		"  Kernel Version: " .. KERNEL_VERSION,
		"  Modern Plugin Support: " .. tostring(SUPPORTS_MODERN_PLUGINS),
		"  Rust Plugin Support: " .. tostring(SUPPORTS_RUST_PLUGINS),
	}
	print(table.concat(info, "\n"))
end

-- Wrapper of print + vim.inspect
P = function(v)
	print(vim.inspect(v))
	return v
end

-- Compiling command
function CompileRun()
	vim.cmd("w")
	if vim.bo.filetype == "c" then
		vim.cmd("!gcc % -o %<")
		vim.cmd("!time ./%<")
	elseif vim.bo.filetype == "cpp" then
		vim.cmd("!g++ % -o %<")
		vim.cmd("!time ./%<")
	elseif vim.bo.filetype == "java" then
		vim.cmd("!javac %")
		vim.cmd("!time java %")
	elseif vim.bo.filetype == "sh" then
		vim.cmd("!time bash %")
	elseif vim.bo.filetype == "python" then
		vim.cmd("!time python3 %")
	elseif vim.bo.filetype == "html" then
		vim.cmd("!google-chrome % &")
	elseif vim.bo.filetype == "go" then
		vim.cmd("!go build %<")
		vim.cmd("!time go run %")
	elseif vim.bo.filetype == "matlab" then
		vim.cmd("!time octave %")
	end
end

-- option and bufopt with desc
opt_s = function(description)
	local o = {}
	o.noremap = true
	o.silent = true
	o.desc = description
	return o
end

bopt_s = function(bufnr, description)
	local o = {}
	o.noremap = true
	o.silent = true
	o.buffer = bufnr
	o.desc = description
	return o
end
