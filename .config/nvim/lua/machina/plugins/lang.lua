return {
  -- Yuck syntax (eww widgets)
  "elkowar/yuck.vim",

  -- Justfiles
  {
    "NoahTheDuke/vim-just",
    ft = { "just" },
  },

  -- Crates.io integration
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup {}
    end,
  },

  -- LaTeX
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-shell-escape",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
    end,
  },
  {
    "evesdropper/luasnip-latex-snippets.nvim",
    dependencies = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    ft = { "tex", "latex" },
  },

  -- Rust (rustaceanvim auto-configures rust-analyzer, no lspconfig needed)
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              check = {
                command = "clippy",
              },
            },
          },
        },
      }
    end,
  },

  -- LTeX client-side command handlers (disableRules, hideFalsePositives, addToDictionary)
  { "barreiroleo/ltex_extra.nvim", lazy = true },

  -- Markdown rendering (tables, headings, code blocks)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    opts = {
      overrides = {
        buftype = {
          nofile = { enabled = false },
        },
      },
      heading = {
        sign = false,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        width = "block",
        left_pad = 1,
        right_pad = 2,
        min_width = 40,
        border = true,
        above = "▄",
        below = "▀",
      },
      bullet = {
        icons = { "●", "○", "◆", "◇" },
        right_pad = 1,
      },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
        custom = {
          todo = { raw = "[~]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
          in_progress = { raw = "[/]", rendered = "󰥔 ", highlight = "RenderMarkdownWarn" },
          cancelled = { raw = "[-]", rendered = "󰜺 ", highlight = "RenderMarkdownError" },
          deferred = { raw = "[>]", rendered = "󰒊 ", highlight = "RenderMarkdownInfo" },
          important = { raw = "[!]", rendered = "󰀦 ", highlight = "RenderMarkdownHint" },
        },
      },
      code = {
        sign = false,
        style = "full",
        width = "block",
        left_pad = 2,
        right_pad = 2,
        border = "thin",
      },
      dash = {
        icon = "─",
      },
      quote = {
        icon = "▋",
      },
      link = {
        hyperlink = "󰌹 ",
        custom = {
          web = { pattern = "^http", icon = "󰖟 " },
          github = { pattern = "github%.com", icon = "󰊤 " },
        },
      },
      pipe_table = {
        style = "full",
        border = { "╭", "┬", "╮", "├", "┼", "┤", "╰", "┴", "╯", "│", "─" },
      },
    },
    keys = {
      { "<leader>tm", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown rendering" },
    },
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    config = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
}
