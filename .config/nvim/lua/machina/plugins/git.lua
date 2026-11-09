return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signs_staged = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      attach_to_untracked = true,
      numhl = true,
      linehl = false,
      word_diff = false,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, { expr = true })
        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, { expr = true })
        map("n", "<leader>hs", gs.stage_hunk)
        map("n", "<leader>hr", gs.reset_hunk)
        map("v", "<leader>hs", function() gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end)
        map("v", "<leader>hr", function() gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end)
        map("n", "<leader>hS", gs.stage_buffer)
        map("n", "<leader>hu", gs.undo_stage_hunk)
        map("n", "<leader>hR", gs.reset_buffer)
        map("n", "<leader>hp", gs.preview_hunk)
        map("n", "<leader>hb", function() gs.blame_line { full = true } end)
        map("n", "<leader>tb", gs.toggle_current_line_blame)
        map("n", "<leader>hd", gs.diffthis)
        map("n", "<leader>hD", function() gs.diffthis "~" end)
        map("n", "<leader>td", gs.toggle_deleted)
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
        map("n", "<leader>cm", function() gs.blame_line { full = true } end)
      end,
    },
  },
  {
    "rhysd/committia.vim",
  },
  {
    "pwntester/octo.nvim",
    enabled = function() return vim.fn.executable("gh") == 1 end,
    opts = {
      picker = "snacks",
    },
  },
  {
    "Juksuu/worktrees.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
      -- Find the bare repo root by walking up from a path looking for .bare/
      local function find_bare_root(path)
        local dir = path
        while dir and dir ~= "/" do
          if vim.fn.isdirectory(dir .. "/.bare") == 1 then return dir end
          dir = vim.fn.fnamemodify(dir, ":h")
        end
        return nil
      end

      -- Compute tmux session name matching sessionizer convention
      local function session_name_for(path)
        local bare_root = find_bare_root(path)
        if bare_root then
          local project = vim.fn.fnamemodify(bare_root, ":t"):gsub("%.", "_")
          -- Worktree dir relative to bare root, with slashes and dots as underscores
          local rel = path:sub(#bare_root + 2):gsub("/", "-"):gsub("%.", "_")
          return project .. "-" .. rel, project
        end
        return vim.fn.fnamemodify(path, ":t"):gsub("%.", "_"), nil
      end

      require("worktrees").setup {
        swap_current_buffer = false,
        hooks = {
          on_switch = function(prev_path, new_path)
            -- Restore nvim state (plugin changed cwd, we just want the tmux switch)
            vim.cmd("cd " .. vim.fn.fnameescape(prev_path))
            if not os.getenv("TMUX") then return end
            local name = session_name_for(new_path)
            local esc = vim.fn.shellescape
            vim.fn.system("tmux has-session -t=" .. esc(name) .. " 2>/dev/null || tmux new-session -ds " .. esc(name) .. " -c " .. esc(new_path))
            vim.fn.jobstart("tmux switch-client -t " .. esc(name), { detach = true })
          end,
          on_add = function(_, path)
            -- Run the same post-create steps as Worktrunk hooks
            vim.fn.jobstart("cd " .. vim.fn.shellescape(path) .. " && wt step copy-ignored 2>/dev/null; uv sync 2>/dev/null", {
              on_exit = function(_, code)
                vim.schedule(function()
                  if code == 0 then
                    vim.notify("Worktree ready: copied env + synced deps", vim.log.levels.INFO, { title = "Worktree" })
                  else
                    vim.notify("Worktree created (env copy or uv sync had issues)", vim.log.levels.WARN, { title = "Worktree" })
                  end
                end)
              end,
            })
          end,
          on_remove = function(path)
            if vim.fn.executable("wt") == 1 then
              vim.fn.system("wt remove -y " .. vim.fn.shellescape(vim.fn.fnamemodify(path, ":t")))
            end
            if os.getenv("TMUX") then
              local name, project = session_name_for(path)
              local main_session = project and (project .. "-main") or nil
              if main_session and name ~= main_session then
                vim.fn.system("tmux switch-client -t=" .. vim.fn.shellescape(main_session) .. " 2>/dev/null")
              end
              vim.fn.system("tmux kill-session -t=" .. vim.fn.shellescape(name) .. " 2>/dev/null")
            end
          end,
        },
      }
    end,
    keys = {
      { "<leader>gW", function() Snacks.picker.worktrees() end, desc = "Switch worktree" },
      { "<leader>gA", function() Snacks.picker.worktrees_new() end, desc = "Add worktree" },
      { "<leader>gR", function() Snacks.picker.worktrees_remove() end, desc = "Remove worktree" },
    },
  },
}
