-- Utilities for creating configurations
local util = require("formatter.util")
local formatter = require("formatter")
local utils = require("utils")

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
formatter.setup({
	logging = true,
	log_level = vim.log.levels.DEBUG,
	filetype = {
		-- Formatter configurations for filetypes go here and will be executed in order
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
		java = {
			function()
				local gjfjar =
					utils.get_env("GJF_JAR_FILE", "~/.local/share/google-java-format/google-java-format-all-deps.jar")
				return {
					exe = utils.get_java_bin(),
					args = {
						"-jar",
						gjfjar,
						"-",
					},
					stdin = true,
				}
			end,
		},
		c = {
			require("formatter.filetypes.c").clangformat,
		},
		cpp = {
			require("formatter.filetypes.cpp").clangformat,
		},
		go = {
			require("formatter.filetypes.go").gofmt,
		},
		json = {
			require("formatter.filetypes.json").jsbeautify,
		},
		proto = {
			require("formatter.filetypes.proto").buf_format,
		},
		python = {
			require("formatter.filetypes.python").black,
		},
		yaml = {
			require("formatter.filetypes.yaml").yamlfmt,
		},
		latex = {
			require("formatter.filetypes.latex").latexindent,
		},
		r = {
			require("formatter.filetypes.r").styler,
		},
		rust = {
			require("formatter.filetypes.rust").rustfmt,
		},
		sh = {
			require("formatter.filetypes.sh").shfmt,
		},
		zsh = {
			require("formatter.filetypes.sh").shfmt,
		},
		sql = {
			require("formatter.filetypes.sql").sqlfluff,
		},
		cmake = {
			require("formatter.filetypes.cmake").cmakeformat,
		},
		xhtml = {
			require("formatter.filetypes.xhtml").tidy,
		},
		xml = {
			require("formatter.filetypes.xml").xmllint,
		},
		toml = {
			require("formatter.filetypes.toml").taplo,
		},
		-- Use the special "*" filetype for defining formatter configurations on
		-- any filetype
		["*"] = {
			-- "formatter.filetypes.any" defines default configurations for any
			-- filetype
			require("formatter.filetypes.any").remove_trailing_whitespace,
		},
	},
})
