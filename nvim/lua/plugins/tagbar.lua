-- Displays tags in a window, ordered by scope
return {
	"preservim/tagbar",
	cmd = "TagbarToggle",
	config = function()
		-- Tagbar settings
		vim.g.tagbar_position = "right"
		vim.g.tagbar_sort = 0
		vim.g.tagbar_compact = 1
		vim.g.tagbar_show_data_type = 1
		vim.g.tagbar_indent = 1
		vim.g.tagbar_show_tag_linenumbers = 1
		vim.g.tagbar_zoomwidth = 0
		vim.g.tagbar_autofocus = 1
		vim.g.tagbar_autopreview = 0
		vim.g.tagbar_previewwin_pos = "splitabove"

		-- Haskell
		vim.g.tagbar_type_haskell = {
			ctagsbin = "hasktags",
			ctagsargs = "-x -c -o-",
			kinds = {
				"m:modules:0:1",
				"d:data:0:1",
				"d_gadt:data gadt:0:1",
				"t:type names:0:1",
				"nt:new types:0:1",
				"c:classes:0:1",
				"cons:constructors:1:1",
				"c_gadt:constructor gadt:1:1",
				"c_a:constructor accessors:1:1",
				"ft:function types:1:1",
				"fi:function implementations:0:1",
				"i:instance:0:1",
				"o:others:0:1",
			},
			sro = ".",
			kind2scope = {
				m = "module",
				c = "class",
				d = "data",
				t = "type",
				i = "instance",
			},
			scope2kind = {
				module = "m",
				class = "c",
				data = "d",
				type = "t",
				instance = "i",
			},
		}

		-- Golang
		vim.g.tagbar_type_go = {
			ctagstype = "go",
			kinds = {
				"p:package",
				"i:imports:1",
				"c:constants",
				"v:variables",
				"t:types",
				"n:interfaces",
				"w:fields",
				"e:embedded",
				"m:methods",
				"r:constructor",
				"f:functions",
			},
			sro = ".",
			kind2scope = {
				t = "ctype",
				n = "ntype",
			},
			scope2kind = {
				ctype = "t",
				ntype = "n",
			},
			ctagsbin = "gotags",
			ctagsargs = "-sort -silent",
		}

		-- Rust
		vim.g.rust_use_custom_ctags_defs = 1 -- if using rust.vim
		vim.g.tagbar_type_rust = {
			ctagsbin = "ctags",
			ctagstype = "rust",
			kinds = {
				"n:modules",
				"s:structures:1",
				"i:interfaces",
				"c:implementations",
				"f:functions:1",
				"g:enumerations:1",
				"t:type aliases:1:0",
				"C:constants:1:0",
				"M:macros:1",
				"m:fields:1:0",
				"e:enum variants:1:0",
				"P:methods:1",
			},
			sro = "::",
			kind2scope = {
				n = "module",
				s = "struct",
				i = "interface",
				c = "implementation",
				f = "function",
				g = "enum",
				t = "typedef",
				v = "variable",
				M = "macro",
				m = "field",
				e = "enumerator",
				P = "method",
			},
		}

		-- Keymaps for tagbar
		vim.keymap.set("n", "<leader>tt", ":TagbarToggle<CR>", { desc = "[tagbar] Toggle tagbar" })
		vim.keymap.set("n", "<F9>", ":TagbarToggle<CR>", { desc = "[tagbar] Toggle tagbar" })
	end,
}
