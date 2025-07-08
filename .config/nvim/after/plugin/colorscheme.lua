vim.opt.termguicolors = true

require("rose-pine").setup {
  dark_variant = "main",
  styles = {
    transparency = true,
  },
  groups = {
    border = "muted",
    link = "iris",
    panel = "surface",

    error = "love",
    hint = "iris",
    info = "foam",
    note = "pine",
    todo = "rose",
    warn = "gold",

    git_add = "#6acb8e",
    git_change = "rose",
    git_delete = "love",
    git_dirty = "rose",
    git_ignore = "muted",
    git_merge = "iris",
    git_rename = "pine",
    git_stage = "iris",
    git_text = "rose",
    git_untracked = "subtle",
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

    TreesitterContext = { fg = "subtle", bg = "overlay" },
  },
}
vim.cmd.colorscheme "rose-pine"
