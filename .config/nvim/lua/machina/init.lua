-- Set leader key before loading plugins (required by lazy.nvim)
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/machina/plugins/ (each file returns a table of specs)
require("lazy").setup("machina.plugins")

-- Core configuration
require("machina.options")
require("machina.keymaps")
require("machina.autocmds")
require("machina.lsp")


-- Debug helpers (useful in :lua P(vim.opt.rtp))
P = function(v)
  print(vim.inspect(v))
  return v
end
