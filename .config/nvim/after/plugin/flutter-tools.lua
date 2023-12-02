require("flutter-tools").setup {}

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.dart",
  command = "FlutterReload",
})
