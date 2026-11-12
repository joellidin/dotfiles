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
          vim.schedule(function() gs.nav_hunk "next" end)
          return "<Ignore>"
        end, { expr = true })
        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.nav_hunk "prev" end)
          return "<Ignore>"
        end, { expr = true })
        map("n", "<leader>hs", gs.stage_hunk)
        map("n", "<leader>hr", gs.reset_hunk)
        map("v", "<leader>hs", function() gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end)
        map("v", "<leader>hr", function() gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end)
        map("n", "<leader>hS", gs.stage_buffer)
        map("n", "<leader>hu", gs.stage_hunk) -- stage_hunk on a staged hunk unstages it
        map("n", "<leader>hR", gs.reset_buffer)
        map("n", "<leader>hp", gs.preview_hunk)
        map("n", "<leader>hb", function() gs.blame_line { full = true } end)
        map("n", "<leader>tb", gs.toggle_current_line_blame)
        map("n", "<leader>hd", gs.diffthis)
        map("n", "<leader>hD", function() gs.diffthis "~" end)
        map("n", "<leader>td", gs.preview_hunk_inline)
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
      local herdr = require("machina.herdr")

      require("worktrees").setup {
        swap_current_buffer = false,
        hooks = {
          on_switch = function(prev_path, new_path)
            -- Restore nvim state (plugin changed cwd, we just want the herdr switch)
            vim.cmd("cd " .. vim.fn.fnameescape(prev_path))
            if not herdr.in_herdr() then return end
            -- Focus the worktree's workspace or create it; the sessionizer owns the naming
            if vim.fn.executable("herdr-sessionizer") == 0 then
              vim.notify("herdr-sessionizer not found", vim.log.levels.WARN, { title = "Worktree" })
              return
            end
            vim.system({ "herdr-sessionizer", new_path }, { detach = true, stdout = false }, function(res)
              if res.code ~= 0 then
                vim.schedule(function()
                  vim.notify("herdr-sessionizer failed: " .. vim.trim(res.stderr or ""), vim.log.levels.WARN, { title = "Worktree" })
                end)
              end
            end)
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
              vim.system({ "wt", "remove", "-y", vim.fn.fnamemodify(path, ":t") }):wait()
            end
            if not herdr.in_herdr() then return end
            -- Move to <project>-main unless that is the one going away
            local name, project = herdr.workspace_name(path)
            local list = herdr.workspaces()
            local main_label = project and (project .. "-main")
            if main_label and name ~= main_label then
              local main = herdr.find_by_label(main_label, list)[1]
              if main then herdr.focus(main.workspace_id) end
            end
            -- Close the worktree's workspace, as tmux kill-session did. Exact label match only.
            local matches = herdr.find_by_label(name, list)
            if #matches == 1 then
              herdr.close(matches[1].workspace_id)
            elseif #matches > 1 then
              vim.notify(("%d herdr workspaces are labelled %s; closing none"):format(#matches, name),
                vim.log.levels.WARN, { title = "Worktree" })
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
