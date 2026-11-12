-- Move between Neovim splits and herdr panes with the same keys. smart-splits moves inside Neovim; past Neovim's
-- edge it asks herdr to focus the neighbouring pane. smart-splits has no herdr backend, so no backend resolves and
-- `at_edge` runs at every Neovim edge. Outside herdr it stops there.
-- Test: sh ~/.claude/plans/test-nvim-splits-lsp.sh
return {
  {
    "smart-splits-nvim/smart-splits.nvim",
    lazy = false,
    config = function()
      local ss = require("smart-splits")
      ss.setup {
        move = {
          at_edge = function(ctx)
            if not vim.env.HERDR_ENV then return end
            local herdr = vim.env.HERDR_BIN_PATH or "herdr"
            vim.system({ herdr, "pane", "focus", "--direction", ctx.direction, "--current" }, { detach = true })
          end,
        },
      }
      -- Navigation
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
