local fn = vim.fn
local execute = vim.api.nvim_command

-- Auto install packer.nvim if not exists
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end
vim.cmd [[packadd packer.nvim]]
vim.cmd "autocmd BufWritePost joel/plugins.lua PackerCompile" -- Auto compile when there are changes in plugins.lua

vim.g.mapleader = " "
-- Install plugins
require "joel.plugins"
-- Lsp Settings
require "joel.lsp"
-- General configs
require "joel.configs"
-- Global settings
require "joel.globals"
--Telescope settings
require "joel.telescope.setup"
require "joel.telescope.mappings"
