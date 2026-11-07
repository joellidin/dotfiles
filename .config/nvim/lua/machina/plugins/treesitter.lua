-- nvim-treesitter's `master` branch is archived and does not support Neovim
-- 0.12+, so this uses the `main` branch. There Neovim itself provides
-- highlighting, folding, injections and incremental selection; the plugin only
-- installs parsers and queries (into stdpath("data") .. "/site").

local ensure_installed = {
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
  "markdown_inline",
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
}

-- Languages that keep regex highlighting (was `highlight.disable`).
local highlight_disable = { json = true }

local swap_objects = {
  p = "@parameter.inner",
  f = "@function.outer",
  e = "@element",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup {}
      ts.install(ensure_installed) -- async, no-op once installed

      local function start(buf, lang)
        if vim.api.nvim_buf_is_valid(buf) then
          pcall(vim.treesitter.start, buf, lang)
        end
      end

      local available ---@type string[]?
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("machina_treesitter", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang or highlight_disable[lang] then
            return
          end
          local ok, added = pcall(vim.treesitter.language.add, lang)
          if ok and added then
            start(args.buf, lang)
            return
          end
          -- Was `auto_install = true`: fetch a missing parser on first use.
          available = available or ts.get_available()
          if vim.tbl_contains(available, lang) then
            ts.install({ lang }):await(function(err)
              if not err then
                start(args.buf, lang)
              end
            end)
          end
        end,
      })

      -- Incremental selection is built into Neovim 0.13 (:h vim.treesitter.select()).
      vim.keymap.set({ "n", "x" }, "<M-w>", function() vim.treesitter.select("parent") end, { desc = "Select node / expand to parent" })
      vim.keymap.set("x", "<M-C-w>", function() vim.treesitter.select("child") end, { desc = "Shrink selection to child node" })

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
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    init = function()
      -- The built-in Python ftplugin maps ]] [[ ]m [m etc.; keep the treesitter ones.
      vim.g.no_python_maps = true
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup { move = { set_jumps = true } }

      local select_keys = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@conditional.outer",
        ["ic"] = "@conditional.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      }
      for key, query in pairs(select_keys) do
        vim.keymap.set({ "x", "o" }, key, function()
          require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
        end, { desc = "Select " .. query })
      end

      local moves = {
        goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
        goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
        goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
        goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
      }
      for fn, keys in pairs(moves) do
        for key, query in pairs(keys) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            require("nvim-treesitter-textobjects.move")[fn](query, "textobjects")
          end, { desc = (fn:gsub("_", " ")) .. " " .. query })
        end
      end

      for key, query in pairs(swap_objects) do
        vim.keymap.set("n", string.format("<M-Space><M-%s>", key), function()
          require("nvim-treesitter-textobjects.swap").swap_next(query)
        end, { desc = "Swap next " .. query })
        vim.keymap.set("n", string.format("<M-BS><M-%s>", key), function()
          require("nvim-treesitter-textobjects.swap").swap_previous(query)
        end, { desc = "Swap previous " .. query })
      end
    end,
  },
}
