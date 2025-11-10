-- Code style formatter
return {
	"stevearc/conform.nvim",
	event = "VimEnter",
	config = function()
		local conform = require("conform")
		local utils = require("utils")

		-- Setup conform.nvim
		conform.setup({
			log = true,
			log_level = vim.log.levels.DEBUG,
			formatters_by_ft = {
				-- Formatter configurations for filetypes
				lua = { "stylua" },
				java = { "google_java_format" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				go = { "gofmt" },
				json = { "prettierd", "prettier" },
				proto = { "buf" },
				python = { "black" },
				yaml = { "yamlfmt" },
				latex = { "latexindent" },
				r = { "styler" },
				rust = { "rustfmt" },
				sh = { "shfmt" },
				zsh = { "shfmt" },
				sql = { "sqlfluff" },
				cmake = { "cmake_format" },
				xhtml = { "tidy" },
				xml = { "xmllint" },
				toml = { "taplo" },
			},
			-- Format on save configuration (disabled)
			-- format_on_save = {
			-- 	timeout_ms = 500,
			-- 	lsp_fallback = true,
			-- },
			-- Custom formatters
			formatters = {
				google_java_format = {
					command = utils.get_java_bin(),
					args = function()
						local gjfjar = utils.get_env(
							"GJF_JAR_FILE",
							"~/.local/share/google-java-format/google-java-format-all-deps.jar"
						)
						return { "-jar", vim.fn.expand(gjfjar), "-" }
					end,
					stdin = true,
				},
			},
		})

		-- Create Format and FormatWrite commands
		vim.api.nvim_create_user_command("Format", function(args)
			local range = nil
			if args.range ~= 0 then
				range = {
					start = { args.line1, 0 },
					["end"] = { args.line2, 0 },
				}
			end
			conform.format({ async = true, lsp_fallback = true, range = range })
		end, { range = true, desc = "Format code with conform.nvim" })

		vim.api.nvim_create_user_command("FormatWrite", function(args)
			local range = nil
			if args.range ~= 0 then
				range = {
					start = { args.line1, 0 },
					["end"] = { args.line2, 0 },
				}
			end
			conform.format({ async = false, lsp_fallback = true, range = range })
			vim.cmd("write")
		end, { range = true, desc = "Format code and write buffer with conform.nvim" })

		-- Create keymap after commands are created
		vim.keymap.set("n", "<leader>af", "<cmd>Format<cr>", { desc = "Format code" })
	end,
}
