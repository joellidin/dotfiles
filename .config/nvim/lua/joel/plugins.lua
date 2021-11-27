local packer = require('packer')
local util = require('packer.util')

packer.init {
    compile_path = util.join_paths(vim.fn.stdpath('config'), 'packer', 'packer_compiled.vim')
}

packer.startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- LSP
  use 'neovim/nvim-lspconfig'
  -- use 'tamago324/nlsp-settings.nvim' -- Does not work
  use 'L3MON4D3/LuaSnip' -- Snippets plugin

  -- This is a requirement, which implements some useful window management
  --   items for neovim
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/popup.nvim'

  -- Telescope
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-telescope/telescope-fzf-writer.nvim' -- requires fzf and ripgrep
  use 'nvim-telescope/telescope-packer.nvim'
  use 'nvim-telescope/telescope-fzy-native.nvim'
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'nvim-telescope/telescope-hop.nvim' -- Unsure about this one
  use 'nvim-telescope/telescope-github.nvim' -- Need github-cli
  use 'nvim-telescope/telescope-symbols.nvim'
  use { -- Sort files in how often you open them
    "nvim-telescope/telescope-frecency.nvim",
    config = function()
      require"telescope".load_extension("frecency")
    end,
    requires = {"tami5/sqlite.lua"}
  }
  use { -- Search on the web from telescope
    "nvim-telescope/telescope-arecibo.nvim",
    rocks = {"openssl", "lua-http-parser"}
  }

  -- Nice plugin to remember what you have copied
  use {
    "AckslD/nvim-neoclip.lua",
    config = function()
      require('neoclip').setup()
    end,
  }

  -- Git
  use "TimUntersberger/neogit"

  -- Github integration
  if vim.fn.executable "gh" == 1 then
    use "pwntester/octo.nvim"
  end

  -- Completion
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-buffer' -- For completing words in current buffer
  use 'hrsh7th/cmp-path' -- For completing paths
  use 'hrsh7th/cmp-nvim-lua' -- Nice completion for lua and nvim
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-cmdline' -- For vims cmdline
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp

  use "onsails/lspkind-nvim" -- Add vscode-like pictograms to neovim built-in lsp

  -- Colorschemes (might be temporary)
  use 'tjdevries/colorbuddy.vim'
  use 'tjdevries/gruvbuddy.nvim'

  -- Pretty colors
  use 'norcalli/nvim-colorizer.lua'
  use {
    "norcalli/nvim-terminal.lua",
    config = function()
      require("terminal").setup()
    end,
  }

  -- Icons
  use 'yamatsum/nvim-nonicons'
  use "kyazdani42/nvim-web-devicons"

  -- Notify 
  use "rcarriga/nvim-notify"

end)
