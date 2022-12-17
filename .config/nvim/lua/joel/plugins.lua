local packer = require "packer"
local util = require "packer.util"

packer.init {
  compile_path = util.join_paths(vim.fn.stdpath "config", "packer", "packer_compiled.vim"),
}

packer.startup(function(use)
  -- Packer can manage itself
  use "wbthomason/packer.nvim"

  use "seandewar/nvimesweeper"
  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  }
  use "nvim-treesitter/nvim-treesitter-context"
  use "nvim-treesitter/nvim-treesitter-textobjects"
  use "nvim-treesitter/nvim-treesitter-refactor"
  use "JoosepAlviste/nvim-ts-context-commentstring"
  use "nvim-treesitter/playground"
  use {
    "mfussenegger/nvim-ts-hint-textobject",
    config = function()
      vim.cmd [[omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>]]
      vim.cmd [[vnoremap <silent> m :lua require('tsht').nodes()<CR>]]
    end,
  }

  -- Yuck
  use "elkowar/yuck.vim"

  -- LSP
  use "neovim/nvim-lspconfig"
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"
  use "ray-x/lsp_signature.nvim"
  -- use 'tamago324/nlsp-settings.nvim' -- Does not work
  use "L3MON4D3/LuaSnip" -- Snippets plugin
  use "tjdevries/nlua.nvim" -- Lua development from tjdevries

  -- This is a requirement, which implements some useful window management
  -- items for neovim
  use "nvim-lua/plenary.nvim"
  use "nvim-lua/popup.nvim"

  -- null-ls
  use "jose-elias-alvarez/null-ls.nvim"

  -- Telescope
  use "nvim-telescope/telescope.nvim"
  use "nvim-telescope/telescope-fzf-writer.nvim" -- requires fzf and ripgrep
  use "nvim-telescope/telescope-packer.nvim"
  use "nvim-telescope/telescope-fzy-native.nvim"
  use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }
  use "nvim-telescope/telescope-hop.nvim" -- Unsure about this one
  use { "nvim-telescope/telescope-file-browser.nvim" } -- Telescope file browser
  use "nvim-telescope/telescope-github.nvim" -- Need github-cli
  use "nvim-telescope/telescope-symbols.nvim"
  use { "nvim-telescope/telescope-smart-history.nvim" }

  use { "tami5/sqlite.lua" } -- Required for frecency
  use { "nvim-telescope/telescope-frecency.nvim" }
  -- use { -- Search on the web from telescope
  --   "nvim-telescope/telescope-arecibo.nvim",
  --   rocks = { "openssl", "lua-http-parser" },
  --   enable = false,
  -- }

  -- Nice plugin to remember what you have copied
  use {
    "AckslD/nvim-neoclip.lua",
    config = function()
      require("neoclip").setup()
    end,
  }

  -- Git
  use "TimUntersberger/neogit"
  use "sindrets/diffview.nvim"
  use "rhysd/committia.vim"
  -- Floating windows are awesome :)
  use {
    "rhysd/git-messenger.vim",
    keys = "<Plug>(git-messenger)",
  }
  use "ruifm/gitlinker.nvim"

  -- Async signs!
  use "lewis6991/gitsigns.nvim"

  -- Github integration
  if vim.fn.executable "gh" == 1 then
    use "pwntester/octo.nvim"
  end

  -- Github copilot
  use { "github/copilot.vim", disable = true }

  -- Completion
  use "hrsh7th/nvim-cmp" -- Autocompletion plugin
  use "hrsh7th/cmp-buffer" -- For completing words in current buffer
  use "hrsh7th/cmp-path" -- For completing paths
  use "hrsh7th/cmp-nvim-lua" -- Nice completion for lua and nvim
  use "hrsh7th/cmp-nvim-lsp" -- LSP source for nvim-cmp
  use "hrsh7th/cmp-cmdline" -- For vims cmdline
  use "saadparwaiz1/cmp_luasnip" -- Snippets source for nvim-cmp
  use "petertriho/cmp-git"

  use "onsails/lspkind-nvim" -- Add vscode-like pictograms to neovim built-in lsp

  --
  use {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()
    end,
  }

  -- Colorschemes (might be temporary)
  use "tjdevries/colorbuddy.vim"
  use "tjdevries/gruvbuddy.nvim"
  use "marko-cerovac/material.nvim"
  use "folke/tokyonight.nvim"

  -- Pretty colors
  use "norcalli/nvim-colorizer.lua"
  use {
    "norcalli/nvim-terminal.lua",
    config = function()
      require("terminal").setup()
    end,
  }

  -- Icons
  use { "yamatsum/nvim-nonicons", disable = true }
  use "kyazdani42/nvim-web-devicons"

  -- Startup
  use { "goolord/alpha-nvim", requires = "kyazdani42/nvim-web-devicons" }

  -- Notify
  use "rcarriga/nvim-notify"

  -- Comment
  use {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  }

  -- Statusline
  use "nvim-lualine/lualine.nvim"
  use "nvim-lua/lsp-status.nvim" -- Research how to use this

  -- Markdown
  use "iamcco/markdown-preview.nvim"

  -- Harpoon for easy navigating in project
  use "ThePrimeagen/harpoon"

  -- Plugin for help with refactoring
  use "ThePrimeagen/refactoring.nvim"
end)
