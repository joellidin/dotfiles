return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      notifier = { enabled = true },
      input = { enabled = true },
      bigfile = { enabled = true },
      styles = {
        input = {
          relative = "cursor",
          row = -3,
          col = 0,
        },
      },
      indent = { enabled = true },
      dashboard = {
        enabled = true,
        width = 80,
        preset = {
          header = require("utils.shared").random_header(),
          keys = {
            { icon = " ", key = "e", desc = "New file", action = ":ene" },
            {
              icon = " ",
              key = "r",
              desc = "Recents",
              action = function()
                Snacks.picker.recent()
              end,
            },
            { icon = " ", key = "s", desc = "Sync plugins", action = ":Lazy sync" },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = function()
                Snacks.picker.files { cwd = "~/.config/nvim" }
              end,
            },
            {
              icon = " ",
              key = "f",
              desc = "Find files",
              action = function()
                Snacks.picker.files()
              end,
            },
            {
              icon = " ",
              key = "g",
              desc = "Live grep",
              action = function()
                Snacks.picker.grep()
              end,
            },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header", padding = { 0, 2 } },
          { section = "keys", gap = 1, padding = 2 },
          { section = "startup" },
        },
      },
      picker = {
        enabled = true,
        prompt = "❯ ",
        layout = {
          -- Custom layout matching old telescope: input top, results below, preview right
          layout = {
            box = "horizontal",
            backdrop = false,
            width = 0.95,
            height = 0.85,
            border = "none",
            {
              box = "vertical",
              { win = "input", height = 1, border = true, title = "{title} {live} {flags}", title_pos = "center" },
              { win = "list", title = " Results ", title_pos = "center", border = true },
            },
            {
              win = "preview",
              title = "{preview:Preview}",
              width = 0.5,
              border = true,
              title_pos = "center",
            },
          },
        },
        win = {
          input = {
            keys = {
              ["<C-s>"] = { "edit_split", mode = { "i", "n" } },
              ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
              ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
            },
          },
          list = {
            keys = {
              ["<C-d>"] = "preview_scroll_down",
              ["<C-u>"] = "preview_scroll_up",
            },
          },
        },
        matcher = {
          frecency = true,
        },
        sources = {
          explorer = {
            auto_close = true,
            layout = { preview = true },
          },
          select = {
            hidden = { "preview" },
            layout = {
              layout = {
                backdrop = false,
                width = 0.4,
                min_width = 60,
                max_width = 80,
                height = 0.4,
                min_height = 2,
                box = "vertical",
                border = true,
                title = "{title}",
                title_pos = "center",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
              },
            },
          },
          lines = {
            layout = {
              preset = "dropdown",
              layout = { width = 0.5, height = 0.4 },
            },
          },
          commands = {
            layout = {
              preset = "dropdown",
              layout = { width = 0.4, height = 0.4 },
            },
          },
        },
      },
    },
    keys = {
      -- Dotfiles
      {
        "<leader>en",
        function()
          Snacks.picker.files { cwd = "~/.config/nvim" }
        end,
        desc = "Edit neovim config",
      },
      {
        "<leader>ez",
        function()
          Snacks.picker.files { cwd = "~/.config/zsh", hidden = true }
        end,
        desc = "Edit zsh config",
      },

      -- Files
      {
        "<leader>ft",
        function()
          Snacks.picker.git_files()
        end,
        desc = "Git files",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>fd",
        function()
          Snacks.picker.files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fe",
        function()
          Snacks.picker.explorer()
        end,
        desc = "File explorer",
      },
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.lines()
        end,
        desc = "Search current buffer",
      },
      {
        "<leader>fh",
        function()
          Snacks.picker.help()
        end,
        desc = "Help tags",
      },
      {
        "<leader>fi",
        function()
          Snacks.picker.files { hidden = true, ignored = true }
        end,
        desc = "All files (incl hidden)",
      },
      {
        "<leader>fa",
        function()
          Snacks.picker.files { cwd = vim.fn.stdpath "data" .. "/lazy" }
        end,
        desc = "Installed plugins",
      },
      {
        "<leader>fz",
        function()
          local ft = vim.fn.input "File type: "
          if ft ~= "" then
            Snacks.picker.files { args = { "--type", ft } }
          end
        end,
        desc = "Search by file type",
      },

      -- Git
      {
        "<leader>gs",
        function()
          Snacks.picker.git_status()
        end,
        desc = "Git status",
      },
      {
        "<leader>gc",
        function()
          Snacks.picker.git_log()
        end,
        desc = "Git commits",
      },

      -- Grep
      {
        "<leader>gw",
        function()
          Snacks.picker.grep_word()
        end,
        desc = "Grep word under cursor",
      },
      {
        "<leader>gp",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep with prompt",
      },
      {
        "<leader>f/",
        function()
          local register = vim.fn.getreg "/"
          if register == "" then
            vim.notify("No previous search", vim.log.levels.WARN)
            return
          end
          -- Convert Vim word boundaries to ripgrep, strip other Vim-specific atoms
          register = register:gsub("\\<", "\\b"):gsub("\\>", "\\b"):gsub("\\[CcvVm]", "")
          Snacks.picker.grep { search = register }
        end,
        desc = "Grep last search",
      },

      -- Nvim
      {
        "<leader>bo",
        function()
          Snacks.picker.commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>wt",
        function()
          Snacks.picker.treesitter()
        end,
        desc = "Treesitter symbols",
      },

      -- Meta
      {
        "<leader>fB",
        function()
          Snacks.picker.pickers()
        end,
        desc = "All pickers",
      },

      -- Terminal
      {
        "<leader>st",
        function()
          Snacks.terminal.toggle()
        end,
        desc = "Toggle terminal",
        mode = { "n", "t" },
      },
    },
  },
}
