-- LSP Setup for Neovim
-- Organized, concise, and modernized for maintainability

-- === Safely require dependencies ===
local function safe_require(mod)
	local ok, m = pcall(require, mod)
	if not ok then
		vim.notify("lspconfig: Missing dependency: " .. mod, vim.log.levels.ERROR)
		return nil
	end
	return m
end

local lspconfig = safe_require("lspconfig")
local nvim_cmp = safe_require("cmp_nvim_lsp")
local lsp_status = safe_require("lsp-status")
local goto_preview = safe_require("goto-preview")
if not (lspconfig and nvim_cmp and lsp_status and goto_preview) then
	return
end

lsp_status.register_progress()
goto_preview.setup({})

-- Logging: set to 'error' to reduce noise
vim.lsp.set_log_level("error")

-- === Capabilities ===
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = nvim_cmp.default_capabilities(capabilities)
capabilities = vim.tbl_extend("keep", capabilities, lsp_status.capabilities)

-- === Keymaps ===
local function lsp_keymaps(_, bufnr)
	local bopt = function(desc)
		return { buffer = bufnr, desc = desc }
	end
	local print_wf = function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end

	local mappings = {
		{ "n", "gD", vim.lsp.buf.declaration, "[lsp] goto declaration" },
		{ "n", "gd", vim.lsp.buf.definition, "[lsp] goto definition" },
		{ "n", "gpd", goto_preview.goto_preview_definition, "[lsp] preview definition" },
		{ "n", "gi", vim.lsp.buf.implementation, "[lsp] goto implementation" },
		{ "n", "gpi", goto_preview.goto_preview_implementation, "[lsp] preview implementation" },
		{ "n", "gt", vim.lsp.buf.type_definition, "[lsp] type definition" },
		{ "n", "gpt", goto_preview.goto_preview_type_definition, "[lsp] preview type definition" },
		{ "n", "gr", vim.lsp.buf.references, "[lsp] references" },
		{ "n", "gpr", goto_preview.goto_preview_references, "[lsp] preview references" },
		{ "n", "gP", goto_preview.close_all_win, "[lsp] close all windows" },
		{ "n", "gs", vim.lsp.buf.signature_help, "[lsp] show signature help" },
		{ "n", "rn", vim.lsp.buf.rename, "[lsp] rename" },
		{ "n", "ca", vim.lsp.buf.code_action, "[lsp] code action" },
		{ "n", "K", vim.lsp.buf.hover, "[lsp] buffer hover" },
		{ "n", "<leader>lf", vim.lsp.buf.format, "[lsp] format code" },
		{ "n", "<leader>ai", vim.lsp.buf.incoming_calls, "[lsp] incoming calls" },
		{ "n", "<leader>ao", vim.lsp.buf.outgoing_calls, "[lsp] outgoing calls" },
		{ "n", "<leader>gw", vim.lsp.buf.document_symbol, "[lsp] document symbol" },
		{ "n", "<leader>gW", vim.lsp.buf.workspace_symbol, "[lsp] workspace symbol" },
		{ "n", "<leader>gl", print_wf, "[lsp] list workspace folders" },
		{ "n", "<leader>eq", vim.diagnostic.setloclist, "[lsp] diagnostic setloclist" },
		{ "n", "<leader>ee", vim.diagnostic.open_float, "[lsp] diagnostic open float" },
		{ "n", "[d", vim.diagnostic.goto_prev, "[lsp] diagnostic goto previous" },
		{ "n", "]d", vim.diagnostic.goto_next, "[lsp] diagnostic goto next" },
	}
	for _, m in ipairs(mappings) do
		vim.keymap.set(m[1], m[2], m[3], bopt(m[4]))
	end
end

-- === on_attach handler ===
local function common_on_attach(client, bufnr)
	lsp_keymaps(client, bufnr)
	-- lsp-status.nvim (add more per-server customizations here)
	lsp_status.on_attach(client)
end

-- General language servers
local servers = {
	"rust_analyzer",
	"clojure_lsp",
	"metals",
	"cmake",
}

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = common_on_attach,
		capabilities = common_caps,
	})
end

-- Python
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

lspconfig.pyright.setup({
	settings = { python = { pythonPath = get_python_path() } },
	on_attach = common_on_attach,
	capabilities = common_caps,
})

-- Clangd
lspconfig.clangd.setup({
	handlers = lsp_status.extensions.clangd.setup(),
	init_options = {
		clangdFileStatus = true,
	},
	cmd = { "clangd", "--background-index=true" },
	capabilities = common_caps,
	on_attach = function(client, bufnr)
		vim.keymap.set(
			"n",
			"<leader>sh",
			":ClangdSwitchSourceHeader<CR>",
			bopt_s(bufnr, "[clangd] switch source and header")
		)
		common_on_attach(client, bufnr)
	end,
})

-- YAMl
lspconfig.yamlls.setup({
	capabilities = common_caps,
	on_attach = common_on_attach,
	settings = {
		yaml = {
			schemas = {
				["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
			},
		},
	},
})

-- Haskell
lspconfig.hls.setup({
	on_attach = common_on_attach,
	capabilities = common_caps,
	settings = {
		haskell = {
			formattingProvider = "stylish-haskell",
		},
	},
})

-- Golang
local lastRootPath = nil
local gomodpath = vim.trim(vim.fn.system("go env GOPATH")) .. "/pkg/mod"

lspconfig.gopls.setup({
	on_attach = common_on_attach,
	cmd = { "gopls", "serve" },
	filetypes = { "go", "gomod" },
	root_dir = function(fname)
		local fullpath = vim.fn.expand(fname, ":p")
		if string.find(fullpath, gomodpath) and lastRootPath ~= nil then
			return lastRootPath
		end
		local root = lspconfig.util.root_pattern("go.mod", ".git")(fname)
		if root ~= nil then
			lastRootPath = root
		end
		return root
	end,
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
		},
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
	end,
})

-- Java
local function getJavaBinary()
	local jdkhone = os.getenv("JAVA_HOME_4JDTLS")
	if not jdkhome then
		jdkhome = os.getenv("JAVA_HOME")
	end
	if jdkhome then
		return jdkhome .. "/bin/java"
	end
	return "/usr/local/bin/java"
end

local function getJDTLSHome()
	local home = os.getenv("HOME")
	local jdtls_home = os.getenv("JDTLS_HOME")
	if jdtls_home == nil or jdtls_home == "" then
		jdtls_home = home .. "/.local/share/jdt-language-server"
	end
	return jdtls_home
end

local jdtls_home = getJDTLSHome()
local workspace_folder = os.getenv("HOME") .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
lspconfig.jdtls.setup({
	on_attach = common_on_attach,
	capabilities = common_caps,
	cmd = {
		getJavaBinary(),
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx4g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-jar",
		vim.fn.glob(jdtls_home .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
		"-configuration",
		jdtls_home .. "/config_linux",
		"-data",
		workspace_folder,
	},
	single_file_support = true,
	init_options = {
		jvm_args = {},
		workspace = os.getenv("HOME") .. "/.cache/jdtls/workspace",
	},
})
