local map = vim.keymap.set

-- Arrow key training wheels
map("i", "<Up>", '<C-o>:echom "--> k <-- "<CR>', { desc = "Use k instead" })
map("i", "<Down>", '<C-o>:echom "--> j <-- "<CR>', { desc = "Use j instead" })
map("i", "<Right>", '<C-o>:echom "--> l <-- "<CR>', { desc = "Use l instead" })
map("i", "<Left>", '<C-o>:echom "--> h <-- "<CR>', { desc = "Use h instead" })

-- Helpful delete/change into blackhole buffer
map("n", "<leader>d", '"_d', { desc = "Delete without yank" })
map("n", "<leader>c", '"_c', { desc = "Change without yank" })
map("n", "<leader>D", '"_D', { desc = "Delete to EOL without yank" })
map("n", "<leader>C", '"_C', { desc = "Change to EOL without yank" })

-- Opens line below or above the current line
map("i", "<S-CR>", "<C-O>o")
map("i", "<C-CR>", "<C-O>O")

-- Smart j/k: use gj/gk for wrapped lines, add to jumplist for large jumps
-- Ported from tj#jump_direction in autoload/tj.vim
map("n", "j", function()
  if vim.v.count == 0 then
    return "gj"
  elseif vim.v.count > 5 then
    return "m'" .. vim.v.count .. "j"
  else
    return vim.v.count .. "j"
  end
end, { expr = true })

map("n", "k", function()
  if vim.v.count == 0 then
    return "gk"
  elseif vim.v.count > 5 then
    return "m'" .. vim.v.count .. "k"
  else
    return vim.v.count .. "k"
  end
end, { expr = true })

-- Save and execute current file (Lua or VimScript)
-- Ported from tj#save_and_exec in autoload/tj.vim
map("n", "<leader><leader>x", function()
  local ft = vim.bo.filetype
  if ft == "vim" then
    vim.cmd("silent! write")
    vim.cmd("source %")
  elseif ft == "lua" then
    vim.cmd("silent! write")
    vim.cmd("luafile %")
  end
end, { desc = "Save and execute current file" })

-- Make esc leave terminal mode
map("t", "<leader><Esc>", [[<C-\><C-n>]])
map("t", "<Esc><Esc>", [[<C-\><C-n>]])

-- Replace currently selected text with default register without yanking it
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking selection" })

-- Keep cursor centered on search and join
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "J", "mzJ`z")

-- Move selected lines up/down in visual mode
map("v", "J", ":move '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":move '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Quickfix navigation
map("n", "]q", ":cnext<CR>", { desc = "Next quickfix" })
map("n", "[q", ":cprev<CR>", { desc = "Prev quickfix" })

-- Good for Swedish keyboard
map("n", "Ö", ":")

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
