local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
-- Install plugins
require "joel.plugins"
-- Lsp Settings
require "joel.lsp"
-- General configs
require "joel.configs"
-- Global settings
require "joel.globals"
-- Telescope settings
require "joel.telescope.setup"
require "joel.telescope.mappings"
-- Surround plugin from mini.nvim
require("joel.surround").setup {}
