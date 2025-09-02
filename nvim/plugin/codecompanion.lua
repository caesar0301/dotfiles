require("codecompanion").setup({
	opts = {
		log_level = "ERROR",
	},
	adapters = {
		http = {
			customopenai = function()
				return require("codecompanion.adapters").extend("openai_compatible", {
					env = {
						api_key = vim.env.OPENAI_API_KEY,
						url = vim.env.OPENAI_BASE_URL,
					},
					opts = {
						model = vim.env.OPENAI_MODEL,
					},
					schema = {
						model = {
							default = vim.env.OPENAI_MODEL,
						},
						max_tokens = {
							default = 4096,
						},
					},
				})
			end,
		},
	},
	strategies = {
		chat = { adapter = "customopenai" },
		inline = { adapter = "customopenai" },
		agent = { adapter = "customopenai" },
	},
})
