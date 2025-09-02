vim.opt_local.foldmethod = "syntax"
vim.opt_local.foldlevelstart = 1
vim.api.nvim_command("syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend")
function FoldText()
	return vim.fn.substitute(vim.fn.getline(vim.v.foldstart), "{.*", "{...}", "")
end
vim.opt_local.foldtext = "v:lua.FoldText()"
vim.opt_local.expandtab = true
vim.opt_local.cindent = false
