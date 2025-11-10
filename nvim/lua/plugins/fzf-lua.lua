-- Improved fzf.vim written in lua
return {
	"ibhagwan/fzf-lua",
	cmd = {
		"FzfLua",
		"FzfLuaFiles",
		"FzfLuaBuffers",
		"FzfLuaGrep",
		"FzfLuaLiveGrep",
	},
	keys = {
		{ "<leader>ff", "<cmd>FzfLuaFiles<cr>", desc = "Find files" },
		{ "<leader>fg", "<cmd>FzfLuaLiveGrep<cr>", desc = "Live grep" },
		{ "<leader>fb", "<cmd>FzfLuaBuffers<cr>", desc = "Find buffers" },
	},
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		{ "junegunn/fzf", build = ":call fzf#install()" },
	},
}
