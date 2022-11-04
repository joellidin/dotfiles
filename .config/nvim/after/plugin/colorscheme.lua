vim.opt.termguicolors = true

require("colorbuddy").colorscheme "gruvbuddy"
require("colorizer").setup()

local c = require("colorbuddy.color").colors
local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups
local s = require("colorbuddy.style").styles

Group.new("pythonTSType", c.red)
Group.link("@text.note", g.Todo)
