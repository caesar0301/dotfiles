-- Vlime: Common Lisp development environment
return {
	"vlime/vlime",
	ft = { "lisp", "commonlisp" },
	dependencies = { "HiPhish/nvim-cmp-vlime", "kovisoft/paredit" },
	init = function()
		vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/vlime/vim")
	end,
	config = function()
		-- Set Common Lisp implementation to use ros (Roswell)
		vim.g.vlime_cl_impl = "ros"
		-- Define the build server command for ros
		vim.fn.VlimeBuildServerCommandFor_ros = function(vlime_loader, vlime_eval)
			return { "ros", "run", "--load", vlime_loader, "--eval", vlime_eval }
		end
	end,
}
