vim.opt.termguicolors = true

-- require("colorbuddy").colorscheme "gruvbuddy"
-- require("colorizer").setup()
--
-- local c = require("colorbuddy.color").colors
-- local Group = require("colorbuddy.group").Group
-- local g = require("colorbuddy.group").groups
-- local s = require("colorbuddy.style").styles
--
-- Group.new("pythonTSType", c.red)
-- Group.link("@text.note", g.Todo)

-- set ctermbg and guibg to none
require("rose-pine").setup {
  disable_background = true,
}
vim.cmd.colorscheme "rose-pine"
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "TelescopeNormal", { guibg = nil, ctermbg = nil })
-- vim.api.nvim_set_hl(0, "Normal", { guibg = nil, ctermbg = nil })
