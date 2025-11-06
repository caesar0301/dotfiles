-- LSP Setup for Neovim
-- Organized, concise, and modernized for maintainability

-- === Safely require dependencies ===
local utils = require("utils")
local nvim_cmp = utils.safe_require("cmp_nvim_lsp")
local lsp_status = utils.safe_require("lsp-status")
local goto_preview = utils.safe_require("goto-preview")
-- lspconfig.util is still available for utility functions
local lspconfig_util = utils.safe_require("lspconfig.util")
if not (nvim_cmp and lsp_status and goto_preview) then
	return
end

lsp_status.register_progress()
goto_preview.setup({})

-- Logging: set to 'error' to reduce noise
vim.lsp.set_log_level("error")

-- === Capabilities ===
local common_caps = vim.lsp.protocol.make_client_capabilities()
common_caps = nvim_cmp.default_capabilities(common_caps)
common_caps = vim.tbl_extend("keep", common_caps, lsp_status.capabilities)

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
	vim.lsp.config(lsp, {
		on_attach = common_on_attach,
		capabilities = common_caps,
	})
	vim.lsp.enable(lsp)
end

-- Python
vim.lsp.config("pyright", {
	settings = { python = { pythonPath = utils.get_python_path() } },
	on_attach = common_on_attach,
	capabilities = common_caps,
})
vim.lsp.enable("pyright")

-- Clangd
vim.lsp.config("clangd", {
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
			{ buffer = bufnr, desc = "[clangd] switch source and header" }
		)
		common_on_attach(client, bufnr)
	end,
})
vim.lsp.enable("clangd")

-- YAMl
vim.lsp.config("yamlls", {
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
vim.lsp.enable("yamlls")

-- Haskell
vim.lsp.config("hls", {
	on_attach = common_on_attach,
	capabilities = common_caps,
	settings = {
		haskell = {
			formattingProvider = "stylish-haskell",
		},
	},
})
vim.lsp.enable("hls")

-- Golang
local lastRootPath = nil
local gomodpath = utils.safe_system("go env GOPATH", "") .. "/pkg/mod"

vim.lsp.config("gopls", {
	on_attach = common_on_attach,
	cmd = { "gopls", "serve" },
	filetypes = { "go", "gomod" },
	root_dir = function(fname)
		local fullpath = vim.fn.expand(fname, ":p")
		if string.find(fullpath, gomodpath) and lastRootPath ~= nil then
			return lastRootPath
		end
		local root = lspconfig_util and lspconfig_util.root_pattern("go.mod", ".git")(fname) or nil
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
vim.lsp.enable("gopls")

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
	end,
})

-- Java
local jdtls_home = utils.get_jdtls_home()
local workspace_folder = os.getenv("HOME") .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
vim.lsp.config("jdtls", {
	on_attach = common_on_attach,
	capabilities = common_caps,
	cmd = {
		utils.get_java_binary(),
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
vim.lsp.enable("jdtls")
