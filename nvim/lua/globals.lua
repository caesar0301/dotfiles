local uname = vim.loop.os_uname()

-- System detection - use cached uname data to avoid repeated system calls
_G.OS = uname.sysname
_G.IS_MAC = OS == "Darwin"
_G.IS_LINUX = OS == "Linux"
_G.IS_WINDOWS = OS:find("Windows") and true or false

-- Cache WSL detection using uname.release (no shell call needed)
_G.IS_WSL = (function()
	local release = uname.release or ""
	return IS_LINUX and (release:lower():find("microsoft") ~= nil or release:find("WSL") ~= nil)
end)()

-- Kernel version detection - use cached uname.release instead of io.popen
_G.KERNEL_VERSION = (function()
	local release = uname.release or ""
	if release == "" then
		return IS_MAC and "Unknown" or "0.0.0"
	end
	-- Extract major.minor version (e.g., "24.6.0" -> "24.6" or "5.15.0-91-generic" -> "5.15")
	local major, minor = release:match("^(%d+)%.(%d+)")
	if major and minor then
		return major .. "." .. minor
	else
		return release:gsub("%s+", "")
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
-- This function is only meaningful on Linux systems
_G.kernel_meets_requirement = function(min_version)
	if IS_MAC then
		-- On macOS, Darwin kernel is always modern enough
		return true
	elseif IS_LINUX then
		-- On Linux, check kernel version requirements
		return kernel_version_compare(KERNEL_VERSION, min_version or "5.0") >= 0
	else
		-- On other systems, assume support
		return true
	end
end

-- Compatibility flags for plugin loading
-- On macOS, we support modern plugins by default (Darwin kernel is modern)
-- On Linux, we check kernel version requirements
_G.SUPPORTS_MODERN_PLUGINS = IS_MAC or kernel_meets_requirement("5.0")

-- Get full Darwin version for macOS
_G.get_full_darwin_version = function()
	if not IS_MAC then
		return "N/A"
	end

	local handle = io.popen("uname -r 2>/dev/null")
	if not handle then
		return "Unknown"
	end

	local result = handle:read("*a")
	handle:close()

	if not result or result == "" then
		return "Unknown"
	end

	return result:gsub("%s+", "") -- Return full version
end

-- System information display
_G.show_system_info = function()
	local info = {
		"System Information:",
		"  OS: " .. OS,
		"  Linux: " .. tostring(IS_LINUX),
		"  macOS: " .. tostring(IS_MAC),
		"  Windows: " .. tostring(IS_WINDOWS),
		"  WSL: " .. tostring(IS_WSL),
	}

	if IS_MAC then
		table.insert(info, "  Darwin Version: " .. get_full_darwin_version())
		table.insert(info, "  Modern Plugin Support: ✅ (macOS default)")
		table.insert(info, "  Rust Plugin Support: ✅ (macOS default)")
	else
		table.insert(info, "  Kernel Version: " .. KERNEL_VERSION)
		table.insert(info, "  Modern Plugin Support: " .. tostring(SUPPORTS_MODERN_PLUGINS))
	end

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
