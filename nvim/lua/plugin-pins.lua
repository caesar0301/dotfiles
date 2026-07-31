-- Compatible plugin pin matrix for Neovim 0.12.4
--
-- Context:
--   * lazy-config sets defaults.version = "*" (latest semver tag).
--   * That is unsafe for plugins whose newest tag is stale, misnamed, or
--     targets an older Neovim / nvim-treesitter (master) API.
--   * nvim-treesitter must track `main` (rewrite); companion plugins that
--     still call `nvim-treesitter.configs` need tips that know about `main`.
--
-- Conventions used by plugin specs:
--   version = "<tag>"  -> pin exact release (overrides defaults.version)
--   version = false    -> track default branch tip (ignore semver tags)
--   branch  = "..."    -> required when default branch is not what we want
--
-- Target stack: Neovim 0.12.x + nvim-treesitter@main + vim.lsp.config API

local M = {}

-- Core / treesitter stack
M.treesitter = { branch = "main", version = false }
M.plenary = { version = false } -- latest tag v0.1.4 is from 2023
M.web_devicons = { version = false } -- tags stuck at v0.100 (2024)
M.lualine = { version = false } -- only compat-nvim-* tags exist
M.fzf_lua = { version = false } -- only stale tag 0.7
M.bqf = { version = false } -- v1.1.1 lacks treesitter-main shim
M.hlargs = { version = false } -- no releases; tip uses vim.treesitter.language
M.goto_preview = { version = false } -- tags stale vs main
M.nvim_dap = { version = false } -- 0.10.0 tag behind master
M.telescope_fzf_native = { version = false }

-- Semver pins (latest known-compatible with 0.12.4)
M.lspconfig = { version = "v2.11.0" }
M.gitsigns = { version = "v2.1.0" }
M.nvim_tree = { version = "v1.18.0" }
M.telescope = { version = "v0.1.9" } -- stay on 0.1.x stable line
M.which_key = { version = "v3.17.0" }
M.snacks = { version = "v2.31.0" }
M.render_markdown = { version = "v8.13.0" }
M.mini = { version = "v0.18.0" }
M.mini_base16 = { version = "v0.18.0" }
M.conform = { version = "v9.1.0" }
M.luasnip = { version = "v2.5.0" }
M.nvim_surround = { version = "v4.0.5" }
M.nvim_cmp = { version = "v0.0.2" }
M.nvim_autopairs = { version = "0.10.0" }
M.toggleterm = { version = "v2.13.1" }
M.barbar = { version = "v1.9.1" }
M.claudecode = { version = "v0.3.0" }
M.vimtex = { version = "v2.18" }
M.nvim_r = { version = "v1.0.0" }
M.tagbar = { version = "v3.1.1" }
M.markdown_preview = { version = "v0.0.10" }
M.vlime = { version = "v0.4.0" }
M.nvim_cmp_vlime = { version = "v0.5.0" }
M.cmp_under_comparator = { version = "v1.0.1" }
M.colorout = { version = "v1.2.2" }
M.editorconfig = { version = "v1.2.1" }
M.vim_commentary = { version = "v1.3" }
M.vim_expand_region = { version = "v1.2" }
M.vim_javascript = { version = "1.2.5" }
M.vim_flake8 = { version = "1.7" }
M.tabular = { version = "1.0.0" }
M.paredit = { version = "0.9.11" }
M.fzf = { version = "v0.74.1" }
M.ripgrep = { version = "15.2.0" }
M.fd = { version = "v10.4.2" }

-- Untagged / rarely tagged — always track tip
M.no_tags = { version = false }

return M
