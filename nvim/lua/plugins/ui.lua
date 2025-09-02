-- UI and Interface Plugins
return {
  -- Themes
  {
    "tomasiser/vim-code-dark",
    priority = 1000, -- Load colorscheme early
    config = function()
      vim.cmd.colorscheme("codedark")
    end,
  },

  -- Tabline with auto-sizing, clickable tabs, icons, highlighting etc.
  {
    "romgrk/barbar.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "lewis6991/gitsigns.nvim",
    },
  },

  -- Configure neovim statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/lsp-status.nvim",
    },
    config = function()
      require("lualine").setup()
    end,
  },

  -- Folder and file tree view
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "antosha417/nvim-lsp-file-operations",
      "echasnovski/mini.base16",
    },
    config = function()
      -- Load configuration from plugin/nvim-tree.lua
      local config_path = vim.fn.stdpath("config") .. "/plugin/nvim-tree.lua"
      if vim.fn.filereadable(config_path) == 1 then
        dofile(config_path)
      end
    end,
  },

  -- Displays tags in a window, ordered by scope
  {
    "preservim/tagbar",
    cmd = "TagbarToggle",
    config = function()
      -- Load configuration from plugin/tagbar.lua
      local config_path = vim.fn.stdpath("config") .. "/plugin/tagbar.lua"
      if vim.fn.filereadable(config_path) == 1 then
        dofile(config_path)
      end
    end,
  },

  -- shows the context of the currently visible buffer contents
  {
    "wellle/context.vim",
    event = "BufReadPost",
  },

  -- displays a popup with possible keybindings of the command you started typing
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
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
    cmd = { "ToggleTerm", "TermExec" },
    keys = { "<C-\\>" },
    config = function()
      require("toggleterm").setup()
    end,
  },

  -- Web dev icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    config = function()
      -- Load configuration from plugin/web-devicons.lua
      local config_path = vim.fn.stdpath("config") .. "/plugin/web-devicons.lua"
      if vim.fn.filereadable(config_path) == 1 then
        dofile(config_path)
      end
    end,
  },
}