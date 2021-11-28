local opt = vim.opt
-- Set undodir
opt.undodir = "/Users/joellidin/.vim/undo-dir"
opt.undofile = true

-- Set swapfile
opt.swapfile = true
opt.dir = "/Users/joellidin/.vim/tmp/"

-- nvim-web-devicons: https://www.nerdfonts.com/cheat-sheet →     
--require("nvim-web-devicons").setup {
--  override = {
--    zsh = { icon = "", color = "#428850", name = "Zsh" },
--    lua = { icon = "", color = "#4E99DF", name = "Lua" },
--    md = { icon = "", color = "#6BD02B", name = "Md" },
--    [".gitignore"] = { icon = "", color = "#F14E32", name = "GitIgnore" },
--  },
--  default = true,
--}
