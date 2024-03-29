local alpha = require "alpha"
local dashboard = require "alpha.themes.dashboard"
local headers = require("utils.shared").ascii_art

local leader = "<Space>"

local function button(usr_opts, txt, leader_txt, keybind, keybind_opts)
  local sc_after = usr_opts.shortcut:gsub("%s", ""):gsub(leader_txt, "<leader>")

  local default_opts = {
    position = "center",
    cursor = 5,
    width = 50,
    align_shortcut = "right",
    hl_shortcut = "Keyword",
  }
  local opts = vim.tbl_deep_extend("force", default_opts, usr_opts)

  if nil == keybind then
    keybind = sc_after
  end
  keybind_opts = vim.F.if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
  opts.keymap = { "n", sc_after, keybind, keybind_opts }

  local function on_press()
    -- local key = vim.api.nvim_replace_termcodes(keybind .. '<Ignore>', true, false, true)
    local key = vim.api.nvim_replace_termcodes(sc_after .. "<Ignore>", true, false, true)
    vim.api.nvim_feedkeys(key, "t", false)
  end

  return {
    type = "button",
    val = txt,
    on_press = on_press,
    opts = opts,
  }
end

math.randomseed(os.time())
dashboard.section.header.val = headers[math.random(1, #headers)]

dashboard.section.buttons.val = {
  button({ shortcut = "e", hl = { { "NotifyERRORTitle", 2, 3 } } }, "ﱐ  New file", leader, "<cmd>ene<CR>"),
  button({ shortcut = "r", hl = { { "NotifyWARNTitle", 2, 3 } } }, "  Recents", leader, ":Telescope oldfiles<CR>"),
  button({ shortcut = "s", hl = { { "NotifyINFOTitle", 2, 3 } } }, "  Sync plugins", leader, "<cmd>Lazy sync<CR>"),
  button(
    { shortcut = "c", hl = { { "NotifyTRACETitle", 2, 3 } } },
    "  Configurations",
    leader,
    "<Cmd>lua R('joel.telescope')['edit_neovim'](TelescopeMapArgs[' enedit_neovim'])<CR>"
  ),
  button(
    { shortcut = leader .. " f d", hl = { { "Question", 2, 3 } } },
    "  Find files",
    "teststst",
    "<cmd>Telescope find_files<CR>"
  ),
  button(
    { shortcut = leader .. " f g", hl = { { "Tag", 2, 3 } } },
    "ﭨ  Live grep",
    leader,
    "<cmd>Telescope live_grep<CR>"
  ),
  button({ shortcut = "q", hl = { { "TSDanger", 2, 3 } } }, "  Quit", leader, "<cmd>qa<CR>"),
}

-- Footer must be a table so that its height is correctly measured
local num_plugins_loaded = require("lazy").stats().loaded
local num_plugins_tot = require("lazy").stats().count
if num_plugins_tot <= 1 then
  dashboard.section.footer.val = { num_plugins_loaded .. " / " .. num_plugins_tot .. " plugin ﮣ loaded" }
else
  dashboard.section.footer.val = { num_plugins_loaded .. " / " .. num_plugins_tot .. " plugins ﮣ loaded" }
end
dashboard.section.footer.opts.hl = "Comment"

-- Set paddings
local h_header = #dashboard.section.header.val
local h_buttons = #dashboard.section.buttons.val * 2 - 1
local h_footer = #dashboard.section.footer.val
local pad_tot = vim.o.lines - (h_header + h_buttons + h_footer)
local pad_1 = math.ceil(pad_tot * 0.25)
local pad_2 = math.ceil(pad_tot * 0.20)
local pad_3 = math.floor(pad_tot * 0.30)

dashboard.config.layout = {
  { type = "padding", val = pad_1 },
  dashboard.section.header,
  { type = "padding", val = pad_2 },
  dashboard.section.buttons,
  { type = "padding", val = pad_3 },
  dashboard.section.footer,
}

-- Do not show statusline or tabline in alpha buffer
vim.cmd [[ au User AlphaReady if winnr('$') == 1 | set laststatus=0 showtabline=0 | endif | au BufUnload <buffer> set laststatus=3 showtabline=1 ]]

alpha.setup(dashboard.opts)
