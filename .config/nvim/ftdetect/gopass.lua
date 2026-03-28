vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "/dev/shm/gopass-*",
  callback = function()
    vim.bo.filetype = "gopass"
  end,
})
