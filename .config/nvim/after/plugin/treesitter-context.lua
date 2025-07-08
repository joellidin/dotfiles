local nnoremap = function(lhs, rhs)
  vim.keymap.set("n", lhs, rhs, { remap = false })
end

require("treesitter-context").setup {
  enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
  throttle = true, -- Throttles plugin updates (may improve performance)
  max_lines = 5,   -- How many lines the window should span. Values <= 0 mean no limit.
  patterns = {     -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
    -- For all filetypes
    -- Note that setting an entry here replaces all other patterns for this entry.
    -- By setting the 'default' entry below, you can control which nodes you want to
    -- appear in the context window.
    default = {
      "function",
      "method",
      "for",
      "while",
      "if",
      "switch",
      "case",
    },

    rust = {
      "loop_expression",
      "impl_item",
    },

    typescript = {
      "class_declaration",
      "abstract_class_declaration",
      "else_clause",
    },
  },
}

nnoremap("<leader>ct", require("treesitter-context").toggle)
