require("lazy").setup {
  "seandewar/nvimesweeper",
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  "nvim-treesitter/nvim-treesitter-context",
  "nvim-treesitter/nvim-treesitter-textobjects",
  "nvim-treesitter/nvim-treesitter-refactor",
  "JoosepAlviste/nvim-ts-context-commentstring",
  "nvim-treesitter/playground",
  {
    "mfussenegger/nvim-ts-hint-textobject",
    config = function()
      vim.cmd [[omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>]]
      vim.cmd [[vnoremap <silent> m :lua require('tsht').nodes()<CR>]]
    end,
  },

  -- Yuck
  "elkowar/yuck.vim",

  -- LSP
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "ray-x/lsp_signature.nvim",
  "L3MON4D3/LuaSnip", -- Snippets plugin
  "folke/neodev.nvim", -- Lua development from folke
  {
    "zk-org/zk-nvim",
    config = function()
      require("zk").setup {}
    end,
  },

  -- Flutter
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
  },

  -- This is a requirement, which implements some useful window management
  -- items for neovim
  "nvim-lua/plenary.nvim",
  "nvim-lua/popup.nvim",

  -- Telescope
  "nvim-telescope/telescope.nvim",
  "nvim-telescope/telescope-fzf-writer.nvim", -- requires fzf and ripgrep
  "nvim-telescope/telescope-fzy-native.nvim",
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = false },
  "nvim-telescope/telescope-hop.nvim", -- Unsure about this one
  "nvim-telescope/telescope-file-browser.nvim", -- Telescope file browser
  "nvim-telescope/telescope-github.nvim", -- Need github-cli
  "nvim-telescope/telescope-symbols.nvim",
  "nvim-telescope/telescope-smart-history.nvim",

  "tami5/sqlite.lua", -- Required for frecency
  "nvim-telescope/telescope-frecency.nvim",

  -- Nice plugin to remember what you have copied
  {
    "AckslD/nvim-neoclip.lua",
    config = function()
      require("neoclip").setup()
    end,
  },

  -- Git
  "TimUntersberger/neogit",
  { "sindrets/diffview.nvim", enabled = false },
  "rhysd/committia.vim",

  "rhysd/git-messenger.vim",
  "ruifm/gitlinker.nvim",

  -- Async signs!
  "lewis6991/gitsigns.nvim",

  -- Github integration
  {
    "pwntester/octo.nvim",
    enabled = function()
      return vim.fn.executable "gh" == 1
    end,
  },

  -- Github copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        filetypes = {
          rust = true,
        },
        suggestion = {
          keymap = {
            accept = "<M-Space>",
          },
        },
      }
    end,
  },

  -- ChatGPT
  {
    "jackMort/ChatGPT.nvim",
    cmd = "ChatGPT",
    event = "VeryLazy",
    ft = { "markdown", "python", "rust", "go" },
    config = function()
      require("chatgpt").setup {
        api_key_cmd = "gopass show -o secrets/openai-key",
        openai_params = {
          model = "gpt-4-1106-preview",
        },
        openai_edit_params = {
          model = "gpt-4-1106-preview",
        },
        popup_window = {
          border = {
            highlight = "TelescopePreviewBorder",
          },
          win_options = {
            winhighlight = "Normal:TelescopePreviewNormal,FloatBorder:FloatBorder",
          },
        },
        system_window = {
          border = {
            highlight = "TelescopePromptBorder",
          },
          win_options = {
            winhighlight = "Normal:TelescopePromptNormal,FloatBorder:FloatBorder",
          },
        },
        popup_input = {
          border = {
            highlight = "TelescopePromptBorder",
          },
          win_options = {
            winhighlight = "Normal:TelescopePromptNormal,FloatBorder:FloatBorder",
          },
        },
        settings_window = {
          win_options = {
            winhighlight = "Normal:TelescopePromptNormal,FloatBorder:FloatBorder",
          },
        },
      }
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    enabled = false,
  },

  -- Completion
  "hrsh7th/nvim-cmp", -- Autocompletion plugin
  "hrsh7th/cmp-buffer", -- For completing words in current buffer
  "hrsh7th/cmp-path", -- For completing paths
  "hrsh7th/cmp-nvim-lua", -- Nice completion for lua and nvim
  "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
  "hrsh7th/cmp-cmdline", -- For vims cmdline
  "saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
  "petertriho/cmp-git",

  "onsails/lspkind-nvim", -- Add vscode-like pictograms to neovim built-in lsp

  --
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup {}
    end,
  },

  -- Colorschemes
  { "rose-pine/neovim", name = "rose-pine" },
  { "folke/tokyonight.nvim", enabled = false },

  -- Pretty colors
  "norcalli/nvim-colorizer.lua",
  {
    "norcalli/nvim-terminal.lua",
    config = function()
      require("terminal").setup()
    end,
  },

  -- Justfiles syntax
  {
    "NoahTheDuke/vim-just",
    ft = { "just" },
  },

  -- Undotree
  "mbbill/undotree",

  -- Icons
  { "yamatsum/nvim-nonicons", enabled = false },
  "kyazdani42/nvim-web-devicons",

  -- Startup
  { "goolord/alpha-nvim", dependencies = "kyazdani42/nvim-web-devicons" },

  -- Notify
  "rcarriga/nvim-notify",

  -- Comment
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Statusline
  "nvim-lualine/lualine.nvim",
  "nvim-lua/lsp-status.nvim", -- Research how to use this

  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    config = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  -- Harpoon for easy navigating in project
  "ThePrimeagen/harpoon",

  -- Plugin for help with refactoring
  "ThePrimeagen/refactoring.nvim",

  -- Plugin to make tmux work with neovim
  "aserowy/tmux.nvim",
}
