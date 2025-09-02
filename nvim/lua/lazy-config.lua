-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  -- Comment out with gc/gcc/gcap
  "tpope/vim-commentary",

  -- Code style formatter
  "mhartington/formatter.nvim",

  ---------------
  -- UI Interface
  ---------------

  -- Themes
  "tomasiser/vim-code-dark",

  -- Tabline with auto-sizing, clickable tabs, icons, highlighting etc.
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "lewis6991/gitsigns.nvim",
    },
  },

  -- Configure neovim statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/lsp-status.nvim",
    },
  },

  -- Folder and file tree view
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "antosha417/nvim-lsp-file-operations",
      "echasnovski/mini.base16",
    },
  },

  -- Displays tags in a window, ordered by scope
  "preservim/tagbar",

  -- shows the context of the currently visible buffer contents
  "wellle/context.vim",

  -- displays a popup with possible keybindings of the command you started typing
  {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup({})
    end,
  },

  -- easily manage multiple terminal windows
  {
    "akinsho/toggleterm.nvim",
    version = "v2.13.1",
    config = function()
      require("toggleterm").setup()
    end,
  },

  -------------------
  -- Language Servers
  -------------------

  -- Quickstart configs for Nvim LSP
  "neovim/nvim-lspconfig",

  -- Previewing native LSP's goto definition etc. in floating window
  {
    "rmagatti/goto-preview",
    dependencies = {
      "rmagatti/logger.nvim",
    },
    config = function()
      require("goto-preview").setup()
    end,
  },

  -- Code completion for Nvim LSP
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "neovim/nvim-lspconfig",
      { "hrsh7th/cmp-nvim-lsp", branch = "main" },
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "lukas-reineke/cmp-under-comparator",
    },
  },

  -- vscode-like pictograms for neovim LSP completion items
  {
    "onsails/lspkind-nvim",
    config = function()
      require("lspkind").init({
        preset = "codicons",
      })
    end,
  },

  -- Debug Adapter Protocol client implementation for Neovim
  "mfussenegger/nvim-dap",

  ---------------------
  -- Search Enhancement
  ---------------------

  -- Improved fzf.vim written in lua
  {
    "ibhagwan/fzf-lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      { "junegunn/fzf", build = ":call fzf#install()" },
    },
  },

  -- Highly extendable fuzzy finder over file and symbols
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "BurntSushi/ripgrep",
      "nvim-telescope/telescope-fzf-native.nvim",
      "sharkdp/fd",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  -- Better quickfix window in Neovim, polish old quickfix window
  {
    "kevinhwang91/nvim-bqf",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },

  ------------------
  -- Git Integration
  ------------------

  -- Show git diff markers in the sign column
  "airblade/vim-gitgutter",

  -- Generating .gitignore files
  {
    "wintermute-cell/gitignore.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim", -- optional: for multi-select
    },
  },

  -----------------------------
  -- Syntax Highlight (General)
  -----------------------------

  -- Nvim interface to configure tree-sitter and syntax highlighting
  "nvim-treesitter/nvim-treesitter",
  "nvim-treesitter/nvim-treesitter-refactor",

  -- Highlight arguments' definitions and usages, using Treesitter
  {
    "m-demare/hlargs.nvim",
    config = function()
      require("hlargs").setup()
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },

  -- Autopairs supporting multiple characters
  "windwp/nvim-autopairs",

  -- Add/change/delete surrounding delimiter pairs with ease
  {
    "kylechui/nvim-surround",
    version = "v3.1.3",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -------------------
  -- Language Support
  -------------------

  -- CMake integration comparable to vscode-cmake-tools
  {
    "Civitasv/cmake-tools.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("cmake-tools").setup({})
    end,
  },

  -- Markdown support
  "plasticboy/vim-markdown",
  "MeanderingProgrammer/render-markdown.nvim",

  -- Markdown preview in modern browser
  {
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  -- EditorConfig synatx highlighting
  "editorconfig/editorconfig-vim",

  -- Javascript indentation and syntax support
  "pangloss/vim-javascript",

  -- Rlang support for vim
  {
    "jalvesaq/Nvim-R",
    dependencies = {
      "jalvesaq/cmp-nvim-r",
      "jalvesaq/colorout",
      -- {"jalvesaq/zotcite"},
      -- {"jalvesaq/cmp-zotcite"}
    },
  },

  -- LaTeX synatx highlighting
  "lervag/vimtex",

  -- Rust support (conditionally loaded based on system compatibility)
  {
    "rust-lang/rust.vim",
    cond = function()
      if not SUPPORTS_MODERN_PLUGINS then
        -- Show warning message when plugin is not loaded
        vim.defer_fn(function()
          if IS_MAC then
            vim.notify("Rust plugin disabled: Not supported on macOS", vim.log.levels.WARN)
          else
            vim.notify("Rust plugin disabled: Kernel version " .. KERNEL_VERSION .. " < 5.0", vim.log.levels.WARN)
          end
        end, 100)
        return false
      end
      return true
    end,
  },

  -- Haskell synatx highlighting
  "neovimhaskell/haskell-vim",

  -- Python static syntax and style checker using Flake8
  "nvie/vim-flake8",

  -- Ruby synatx highlighting
  "vim-ruby/vim-ruby",

  -- CSV filetype integration
  "chrisbra/csv.vim",
  "godlygeek/tabular",

  -- Common Lisp dev environment for Vim (alternative to Conjure)
  {
    "vlime/vlime",
    init = function()
      vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/vlime/vim")
    end,
    dependencies = {
      "HiPhish/nvim-cmp-vlime",
      "kovisoft/paredit",
    },
  },

  -- AI companion
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "MeanderingProgrammer/render-markdown.nvim",
    },
  },
}, {
  -- Lazy.nvim configuration options
  defaults = {
    lazy = false, -- should plugins be lazy-loaded?
  },
  install = {
    missing = true, -- install missing plugins on startup
    colorscheme = { "codedark" }, -- try to load one of these colorschemes when starting an installation during startup
  },
  checker = {
    enabled = true, -- automatically check for plugin updates
    notify = false, -- get a notification when new updates are found
  },
  change_detection = {
    enabled = true,
    notify = false, -- get a notification when changes are found
  },
  ui = {
    border = "rounded",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})