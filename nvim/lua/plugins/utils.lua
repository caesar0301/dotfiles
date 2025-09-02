-- Utility and AI Plugins
return {
  -- AI companion
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<leader>ai", "<cmd>CodeCompanionChat<cr>", desc = "AI Chat" },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "AI Actions" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "MeanderingProgrammer/render-markdown.nvim",
    },
    config = function()
      -- Load configuration from plugin/codecompanion.lua
      local config_path = vim.fn.stdpath("config") .. "/plugin/codecompanion.lua"
      if vim.fn.filereadable(config_path) == 1 then
        dofile(config_path)
      end
    end,
  },
}