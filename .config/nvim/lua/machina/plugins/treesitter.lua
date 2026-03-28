return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local swap_next, swap_prev = (function()
        local swap_objects = {
          p = "@parameter.inner",
          f = "@function.outer",
          e = "@element",
        }

        local n, p = {}, {}
        for key, obj in pairs(swap_objects) do
          n[string.format("<M-Space><M-%s>", key)] = obj
          p[string.format("<M-BS><M-%s>", key)] = obj
        end

        return n, p
      end)()

      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "bash",
          "bibtex",
          "c",
          "comment",
          "cpp",
          "css",
          "cuda",
          "dockerfile",
          "go",
          "graphql",
          "javascript",
          "json",
          "latex",
          "lua",
          "make",
          "markdown",
          "python",
          "regex",
          "rst",
          "rust",
          "scss",
          "sql",
          "toml",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          use_languagetree = false,
          disable = { "json" },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<M-w>",
            node_incremental = "<M-w>",
            node_decremental = "<M-C-w>",
            scope_incremental = "<M-e>",
          },
        },
        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
            goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
            goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
            goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
          },
          select = {
            enable = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@conditional.outer",
              ["ic"] = "@conditional.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          swap = {
            enable = true,
            swap_next = swap_next,
            swap_previous = swap_prev,
          },
        },
      }

      vim.keymap.set("n", "<space>tp", "<cmd>InspectTree<CR>", { desc = "Inspect treesitter tree" })
      vim.keymap.set("n", "<space>th", "<cmd>Inspect<CR>", { desc = "Inspect highlight under cursor" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup {
        enable = true,
        throttle = true,
        max_lines = 5,
        patterns = {
          default = { "function", "method", "for", "while", "if", "switch", "case" },
          rust = { "loop_expression", "impl_item" },
          typescript = { "class_declaration", "abstract_class_declaration", "else_clause" },
        },
      }
      vim.keymap.set("n", "<leader>tc", require("treesitter-context").toggle, { desc = "Toggle treesitter context" })
    end,
  },
  "nvim-treesitter/nvim-treesitter-textobjects",
}
