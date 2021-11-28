-- Used to run black automatically if in a python file.
-- If the file "pyproject.toml" exists in, use those settings,
-- otherwise use --line-length=100.
--
-- Otherwise doesn't do anything.

if vim.fn.executable "black" == 0 then
  return
end

vim.cmd [[
  augroup BlackAuto
    autocmd BufWritePre *.py :lua require("joel.black").format()
  augroup END
]]
