return {
  -- Undotree
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle undotree" },
    },
  },

  -- Harpoon v2
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add file" })
      vim.keymap.set("n", "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })

      for i = 1, 5 do
        vim.keymap.set("n", string.format("<leader>%s", i), function()
          harpoon:list():select(i)
        end, { desc = "Harpoon file " .. i })
      end
    end,
  },

  -- Refactoring
  {
    "ThePrimeagen/refactoring.nvim",
    config = function()
      require("refactoring").setup {
        prompt_func_return_type = {
          go = false, java = false, cpp = false, c = false, h = false, hpp = false, cxx = false,
        },
        prompt_func_param_type = {
          go = false, java = false, cpp = false, c = false, h = false, hpp = false, cxx = false,
        },
      }

      vim.keymap.set("v", "<leader>re", function() require("refactoring").refactor("Extract Function") end, { desc = "Extract function" })
      vim.keymap.set("v", "<leader>rf", function() require("refactoring").refactor("Extract Function To File") end, { desc = "Extract function to file" })
      vim.keymap.set("v", "<leader>rv", function() require("refactoring").refactor("Extract Variable") end, { desc = "Extract variable" })
      vim.keymap.set("v", "<leader>ri", function() require("refactoring").refactor("Inline Variable") end, { desc = "Inline variable" })
      vim.keymap.set("n", "<leader>rb", function() require("refactoring").refactor("Extract Block") end, { desc = "Extract block" })
      vim.keymap.set("n", "<leader>rbf", function() require("refactoring").refactor("Extract Block To File") end, { desc = "Extract block to file" })
      vim.keymap.set("n", "<leader>ri", function() require("refactoring").refactor("Inline Variable") end, { desc = "Inline variable" })
      vim.keymap.set("v", "<leader>rr", function() require("refactoring").select_refactor() end, { desc = "Refactor menu" })
    end,
  },

  -- Auto-install formatters/linters via mason
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "prettier",
      },
    },
  },

  -- Formatting (manual via <leader>f, no format-on-save)
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        markdown = { "prettier" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
      },
    },
    keys = {
      { "<leader>f", function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end, desc = "Format" },
    },
  },

  -- Keymap discovery
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git/Grep" },
        { "<leader>h", group = "Harpoon/Hunks" },
        { "<leader>o", group = "Obsidian" },
        { "<leader>r", group = "Refactor" },
        { "<leader>R", group = "Remote SSH" },
        { "<leader>t", group = "Toggle" },
        { "<leader>a", group = "AI" },
        { "<leader>w", group = "Workspace" },
        { "<leader>x", group = "Diagnostics" },
        { "<leader>e", group = "Edit config" },
      },
    },
  },

  -- Flash (enhanced motions)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    },
  },

  -- Surround
  { "echasnovski/mini.surround", version = "*", opts = {} },

  -- Remote SSH editing (VS Code-like)
  {
    "amitds1997/remote-nvim.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    cmd = { "RemoteStart", "RemoteStop", "RemoteInfo", "RemoteCleanup", "RemoteConfigDel", "RemoteLog" },
    keys = {
      { "<leader>Rs", "<cmd>RemoteStart<cr>", desc = "Remote SSH connect" },
      { "<leader>Ri", "<cmd>RemoteInfo<cr>", desc = "Remote SSH info" },
      { "<leader>Rx", "<cmd>RemoteStop<cr>", desc = "Remote SSH disconnect" },
    },
    opts = {},
  },

  -- Diagnostics viewer
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
    },
  },
}
