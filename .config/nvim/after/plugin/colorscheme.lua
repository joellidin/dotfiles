vim.opt.termguicolors = true

require("rose-pine").setup {
  dark_variant = "main",
  styles = {
    transparency = true,
  },
  highlight_groups = {
    TelescopeBorder = { fg = "overlay", bg = "overlay" },
    TelescopeNormal = { fg = "subtle", bg = "overlay" },
    TelescopeSelection = { fg = "text", bg = "highlight_med" },
    TelescopeSelectionCaret = { fg = "love", bg = "highlight_med" },
    TelescopeMultiSelection = { fg = "text", bg = "highlight_high" },

    TelescopeTitle = { fg = "base", bg = "love" },
    TelescopePromptTitle = { fg = "base", bg = "pine" },
    TelescopePreviewTitle = { fg = "base", bg = "iris" },

    TelescopePromptNormal = { fg = "text", bg = "surface" },
    TelescopePromptBorder = { fg = "surface", bg = "surface" },

    TreeSitterContext = { fg = "subtle", bg = "overlay" },
  },
}
vim.cmd.colorscheme "rose-pine"
