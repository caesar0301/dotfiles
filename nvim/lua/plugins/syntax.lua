-- Syntax Highlighting and Text Manipulation Plugins
return {
  -- Nvim interface to configure tree-sitter and syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-refactor",
    },
    config = function()
      -- Load configuration from plugin/treesitter.lua
      local config_path = vim.fn.stdpath("config") .. "/plugin/treesitter.lua"
      if vim.fn.filereadable(config_path) == 1 then
        dofile(config_path)
      end
    end,
  },

  -- Treesitter refactor module
  {
    "nvim-treesitter/nvim-treesitter-refactor",
    lazy = true,
  },

  -- Highlight arguments' definitions and usages, using Treesitter
  {
    "m-demare/hlargs.nvim",
    event = "BufReadPost",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("hlargs").setup()
    end,
  },

  -- Autopairs supporting multiple characters
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      -- Load configuration from plugin/autopairs.lua
      local config_path = vim.fn.stdpath("config") .. "/plugin/autopairs.lua"
      if vim.fn.filereadable(config_path) == 1 then
        dofile(config_path)
      end
    end,
  },

  -- Add/change/delete surrounding delimiter pairs with ease
  {
    "kylechui/nvim-surround",
    version = "v3.1.3",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- Comment out with gc/gcc/gcap
  {
    "tpope/vim-commentary",
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gcc", mode = "n" },
      { "gcap", mode = "n" },
    },
  },
}