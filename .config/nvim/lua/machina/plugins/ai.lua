return {
  -- Inline AI suggestions via Copilot LSP
  {
    "folke/sidekick.nvim",
    enabled = false,
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "github/copilot.vim",
    },
  },

  -- Agentic AI chat (Cursor-like)
  {
    "yetone/avante.nvim",
    enabled = false,
    event = "VeryLazy",
    version = false,
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "echasnovski/mini.icons",
    },
    opts = {
      provider = "claude",
      input = {
        provider = "snacks", -- workaround: native provider has a bug (PR #2935)
      },
      providers = {
        claude = {
          model = "claude-sonnet-4-6",
          auth_type = "max",
        },
      },
    },
  },
}
