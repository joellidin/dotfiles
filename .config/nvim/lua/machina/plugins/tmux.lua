return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      local ss = require("smart-splits")
      ss.setup {}
      -- Navigation (same keys as before)
      vim.keymap.set("n", "<C-w>h", ss.move_cursor_left, { desc = "Move to left split/pane" })
      vim.keymap.set("n", "<C-w>j", ss.move_cursor_down, { desc = "Move to below split/pane" })
      vim.keymap.set("n", "<C-w>k", ss.move_cursor_up, { desc = "Move to above split/pane" })
      vim.keymap.set("n", "<C-w>l", ss.move_cursor_right, { desc = "Move to right split/pane" })
      -- Resizing
      vim.keymap.set("n", "<M-h>", ss.resize_left, { desc = "Resize split left" })
      vim.keymap.set("n", "<M-j>", ss.resize_down, { desc = "Resize split down" })
      vim.keymap.set("n", "<M-k>", ss.resize_up, { desc = "Resize split up" })
      vim.keymap.set("n", "<M-l>", ss.resize_right, { desc = "Resize split right" })
    end,
  },
}
