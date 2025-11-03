-- Unified Plugin Configuration for Lazy.nvim
-- This file organizes plugins by category and integrates their configurations
-- for better maintainability and performance

return {
	-- Import plugin specifications from category modules
	{ import = "plugins.ai" },
	{ import = "plugins.ui" },
	{ import = "plugins.lsp" },
	{ import = "plugins.search" },
	{ import = "plugins.git" },
	{ import = "plugins.syntax" },
	{ import = "plugins.languages" },
}
