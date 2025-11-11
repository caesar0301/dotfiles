-- Displays tags in a window, ordered by scope
return {
	"preservim/tagbar",
	cmd = "TagbarToggle",
	keys = {
		{ "<leader>tt", "<cmd>TagbarToggle<CR>", desc = "[tagbar] Toggle tagbar" },
		{ "<F9>", "<cmd>TagbarToggle<CR>", desc = "[tagbar] Toggle tagbar" },
	},
	config = function()
		-- Configure ctags binary path (prefer universal-ctags over BSD/GNU Emacs ctags)
		local function find_ctags()
			-- Check common Homebrew locations
			local brew_paths = {
				"/opt/homebrew/bin/ctags", -- Apple Silicon Mac
				"/usr/local/bin/ctags", -- Intel Mac / Linux
				"/home/linuxbrew/.linuxbrew/bin/ctags", -- Linuxbrew
			}

			for _, path in ipairs(brew_paths) do
				local file = io.open(path, "r")
				if file then
					file:close()
					-- Verify it's universal or exuberant ctags
					local handle = io.popen(path .. " --version 2>/dev/null")
					if handle then
						local version = handle:read("*a")
						handle:close()
						if version:match("Universal") or version:match("Exuberant") then
							return path
						end
					end
				end
			end
			return nil
		end

		local ctags_bin = find_ctags()
		if ctags_bin then
			vim.g.tagbar_ctags_bin = ctags_bin
		end
	end,
}
