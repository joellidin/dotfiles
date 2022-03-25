local nnoremap = function(tbl)
  vim.keymap.set("n", tbl[1], tbl[2], { remap = false })
end

local ok, harpoon = pcall(require, "harpoon")
if not ok then
  return
end

harpoon.setup {}

nnoremap { "<leader>ha", require("harpoon.mark").add_file }
nnoremap { "<leader>hl", require("harpoon.ui").toggle_quick_menu }

for i = 1, 5 do
  nnoremap {
    string.format("<space>%s", i),
    function()
      require("harpoon.ui").nav_file(i)
    end,
  }
  nnoremap {
    string.format("<space>t%s", i),
    function()
      require("harpoon.term").gotoTerminal(i)
    end,
  }
end
