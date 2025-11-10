-- LaTeX syntax highlighting
return {
	"lervag/vimtex",
	ft = { "tex", "latex" },
	config = function()
		-- Vimtex settings
		vim.g.vimtex_compiler_method = "latexmk"

		if _G.IS_MAC then
			vim.g.vimtex_view_method = "skim"
		elseif _G.IS_LINUX then
			vim.g.vimtex_view_method = "zathura"
		end

		vim.g.vimtex_quickfix_mode = 2
		vim.g.vimtex_quickfix_autoclose_after_keystrokes = 1
		vim.g.vimtex_quickfix_open_on_warning = 0
	end,
}
