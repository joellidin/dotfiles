return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup {
        dark_variant = "main",
        styles = { transparency = true },
        groups = {
          border = "muted",
          link = "iris",
          panel = "surface",
          error = "love",
          hint = "iris",
          info = "foam",
          note = "pine",
          todo = "rose",
          warn = "gold",
          git_add = "#6acb8e",
          git_change = "rose",
          git_delete = "love",
          git_dirty = "rose",
          git_ignore = "muted",
          git_merge = "iris",
          git_rename = "pine",
          git_stage = "iris",
          git_text = "rose",
          git_untracked = "subtle",
        },
        highlight_groups = {
          -- Transparent floating windows (hover, signature help, diagnostics)
          NormalFloat = { bg = "NONE" },
          FloatBorder = { fg = "highlight_high", bg = "NONE" },
          FloatTitle = { fg = "base", bg = "iris", bold = true },

          -- Snacks picker styling (borderless, panes separated by bg color)
          SnacksPicker = { fg = "text", bg = "overlay" },
          SnacksPickerBorder = { fg = "overlay", bg = "overlay" },
          SnacksPickerTitle = { fg = "base", bg = "love", bold = true },
          SnacksPickerList = { fg = "text", bg = "overlay" },
          SnacksPickerListBorder = { fg = "overlay", bg = "overlay" },
          SnacksPickerListTitle = { fg = "base", bg = "love", bold = true },
          SnacksPickerListCursorLine = { bg = "highlight_med" },
          SnacksPickerInput = { fg = "text", bg = "surface" },
          SnacksPickerInputBorder = { fg = "surface", bg = "surface" },
          SnacksPickerInputTitle = { fg = "base", bg = "pine", bold = true },
          SnacksPickerPrompt = { fg = "iris", bg = "surface" },
          SnacksPickerPreview = { fg = "text", bg = "overlay" },
          SnacksPickerPreviewBorder = { fg = "overlay", bg = "overlay" },
          SnacksPickerPreviewTitle = { fg = "base", bg = "foam", bold = true },
          SnacksPickerBox = { bg = "overlay" },
          SnacksPickerBoxBorder = { fg = "overlay", bg = "overlay" },

          -- Snacks input (rename, etc.)
          SnacksInputNormal = { fg = "text", bg = "surface" },
          SnacksInputBorder = { fg = "highlight_high", bg = "surface" },
          SnacksInputTitle = { fg = "base", bg = "iris", bold = true },

          TreesitterContext = { fg = "subtle", bg = "overlay" },
        },
      }
      vim.cmd.colorscheme "rose-pine"
    end,
  },

  { "catppuccin/nvim", name = "catppuccin", lazy = true },

  { "rebelot/kanagawa.nvim", lazy = true },

  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup {
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {},
          always_divide_middle = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            "branch",
            "diff",
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              sections = { "error", "warn", "info", "hint" },
            },
          },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      }
      vim.opt.laststatus = 3
    end,
  },

  "kyazdani42/nvim-web-devicons",
}
