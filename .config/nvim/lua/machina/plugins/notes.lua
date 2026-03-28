local vault = vim.fn.expand("~/notes")

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- Disable obsidian's built-in LSP to avoid duplicates with markdown_oxide
      package.loaded["obsidian.lsp"] = nil
      package.preload["obsidian.lsp"] = function()
        return { start = function() return nil end }
      end

      -- Cascading checkbox toggle
      local checkbox_order = { " ", "/", "x", "-" }

      local function get_checkbox(line)
        return line:match("^%s*%- %[(.)]")
      end

      local function checkbox_indent(line)
        return #(line:match("^(%s*)") or "")
      end

      local function set_checkbox(bufnr, row, state)
        local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
        vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, {
          (line:gsub("%- %[.%]", "- [" .. state .. "]", 1)),
        })
      end

      local function bubble_up(bufnr, child_row)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local child_ind = checkbox_indent(lines[child_row + 1])

        local parent_row, parent_ind
        for i = child_row, 1, -1 do
          local ind = checkbox_indent(lines[i])
          if ind < child_ind then
            if get_checkbox(lines[i]) then
              parent_row, parent_ind = i - 1, ind
            end
            break
          end
        end
        if not parent_row then return end

        local all_done, all_open, all_cancelled = true, true, true
        local direct_ind
        for i = parent_row + 2, #lines do
          local ind = checkbox_indent(lines[i])
          if ind <= parent_ind then break end
          local s = get_checkbox(lines[i])
          if s then
            if not direct_ind then direct_ind = ind end
            if ind == direct_ind then
              if s ~= "x" then all_done = false end
              if s ~= " " then all_open = false end
              if s ~= "-" then all_cancelled = false end
            end
          end
        end

        if all_done then
          set_checkbox(bufnr, parent_row, "x")
        elseif all_cancelled then
          set_checkbox(bufnr, parent_row, "-")
        elseif all_open then
          set_checkbox(bufnr, parent_row, " ")
        else
          set_checkbox(bufnr, parent_row, "/")
        end

        bubble_up(bufnr, parent_row)
      end

      local function toggle_cascading()
        local bufnr = vim.api.nvim_get_current_buf()
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local cur = lines[row + 1]

        local state = get_checkbox(cur)
        if not state then return end

        local new
        for i, s in ipairs(checkbox_order) do
          if s == state then
            new = checkbox_order[i % #checkbox_order + 1]
            break
          end
        end
        new = new or " "

        local indent = checkbox_indent(cur)
        set_checkbox(bufnr, row, new)

        for i = row + 2, #lines do
          if checkbox_indent(lines[i]) <= indent then break end
          if get_checkbox(lines[i]) then
            set_checkbox(bufnr, i - 1, new)
          end
        end

        bubble_up(bufnr, row)
      end

      require("obsidian").setup {
        legacy_commands = false,

        completion = {
          blink = false, -- let markdown_oxide handle completions
        },

        workspaces = {
          {
            name = "notes",
            path = vault,
          },
        },

        notes_subdir = "inbox",

        daily_notes = {
          folder = "journal/daily",
          date_format = "%Y-%m-%d",
          default_tags = { "daily" },
          template = "daily.md",
          workdays_only = false,
        },

        ---@diagnostic disable-next-line: missing-fields
        templates = {
          folder = "templates",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M",
        },

        note_id_func = function(title)
          if title then
            return title:gsub(" ", "-"):gsub("[^A-Za-z0-9_-]", ""):lower()
          end
          return tostring(os.time())
        end,

        ---@diagnostic disable-next-line: missing-fields
        frontmatter = {
          func = function(note)
            -- Replicate the default behavior
            local out = { aliases = note.aliases, tags = note.tags or {} }
            if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
              for k, v in pairs(note.metadata) do
                out[k] = v
              end
            end
            -- Auto-tag notes under projects/
            local rel = note.path and tostring(note.path) or ""
            if rel:match("/projects/") and not vim.tbl_contains(out.tags, "project") then
              table.insert(out.tags, "project")
            end
            return out
          end,
        },

        picker = {
          name = "snacks.pick",
        },

        preferred_link_style = "wiki",

        ---@diagnostic disable-next-line: missing-fields
        ui = {
          enable = false,
        },

        checkbox = {
          enabled = true,
          create_new = true,
          order = { " ", "/", "x", "-" },
        },
      }

      -- Set custom <CR> keymap via User autocmd (more robust than enter_note
      -- callback, which can silently fail if Note.from_buffer errors)
      vim.api.nvim_create_autocmd("User", {
        pattern = "ObsidianNoteEnter",
        callback = function()
          vim.opt_local.conceallevel = 2
          vim.keymap.set("n", "<CR>", function()
            if get_checkbox(vim.api.nvim_get_current_line()) then
              toggle_cascading()
            else
              local keys = require("obsidian.actions").smart_action()
              if keys and keys ~= "" then
                vim.api.nvim_feedkeys(
                  vim.api.nvim_replace_termcodes(keys, true, false, true),
                  "m", false
                )
              end
            end
          end, { buffer = true, desc = "Toggle checkbox / smart action" })
        end,
      })

      -- Strikethrough for completed checkboxes
      local strike_ns = vim.api.nvim_create_namespace("obsidian_strikethrough")

      local function apply_strikethrough(bufnr)
        vim.api.nvim_buf_clear_namespace(bufnr, strike_ns, 0, -1)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local in_checked = false
        local check_indent = 0
        for i, line in ipairs(lines) do
          local text_start = line:find("%- %[x%]%s*") or line:find("%- %[%-%]%s*")
          if text_start then
            -- Start of a checked or cancelled item
            in_checked = true
            check_indent = text_start
            local marker_end = line:find("%]", text_start) + 1
            local after = marker_end + (line:sub(marker_end + 1, marker_end + 1) == " " and 1 or 0)
            if after <= #line then
              vim.api.nvim_buf_set_extmark(bufnr, strike_ns, i - 1, after, {
                end_col = #line,
                hl_group = "ObsidianStrikethrough",
              })
            end
          elseif in_checked then
            -- Continuation line: indented more than the checkbox, not a new list item
            local indent = #(line:match("^(%s*)") or "")
            if indent > check_indent and not line:match("^%s*-%s+%[") then
              vim.api.nvim_buf_set_extmark(bufnr, strike_ns, i - 1, indent, {
                end_col = #line,
                hl_group = "ObsidianStrikethrough",
              })
            else
              in_checked = false
            end
          end
        end
      end

      vim.api.nvim_set_hl(0, "ObsidianStrikethrough", { strikethrough = true, fg = "#808080" })

      vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
        pattern = vault .. "/**/*.md",
        callback = function(ev)
          apply_strikethrough(ev.buf)
        end,
      })

      -- Auto-pull on first vault open
      local pulled = false
      vim.api.nvim_create_autocmd("BufReadPre", {
        pattern = vault .. "/**/*.md",
        callback = function()
          if not pulled then
            pulled = true
            vim.schedule(function()
              vim.notify("Touch YubiKey to pull...", vim.log.levels.INFO, { title = "Notes" })
            end)
            vim.fn.jobstart({ "git", "-C", vault, "pull", "--rebase" }, {
              on_exit = function(_, code)
                if code == 0 then
                  vim.schedule(function()
                    vim.cmd("checktime")
                    vim.notify("Vault pulled", vim.log.levels.INFO, { title = "Notes" })
                  end)
                elseif code ~= 0 then
                  vim.schedule(function()
                    vim.notify("Pull failed (exit " .. code .. ")", vim.log.levels.ERROR, { title = "Notes" })
                  end)
                end
              end,
            })
          end
        end,
      })

      -- Auto-commit on save
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = vault .. "/**/*.md",
        callback = function(ev)
          local file = vim.fn.fnamemodify(ev.file, ":t")
          vim.fn.jobstart({ "git", "-C", vault, "add", "-A" }, {
            on_exit = function()
              vim.schedule(function()
                vim.notify("Touch YubiKey to commit...", vim.log.levels.INFO, { title = "Notes" })
              end)
              vim.fn.jobstart(
                { "git", "-C", vault, "commit", "-m", "auto: update " .. file },
                {
                  on_exit = function(_, code)
                    if code == 0 then
                      vim.fn.jobstart({ "git", "-C", vault, "push" }, {
                        on_exit = function(_, push_code)
                          vim.schedule(function()
                            if push_code == 0 then
                              vim.notify("Synced: " .. file, vim.log.levels.INFO, { title = "Notes" })
                            else
                              vim.notify("Push failed (exit " .. push_code .. ")", vim.log.levels.ERROR, { title = "Notes" })
                            end
                          end)
                        end,
                      })
                    elseif code ~= 1 then
                      vim.schedule(function()
                        vim.notify("Commit failed (exit " .. code .. ")", vim.log.levels.ERROR, { title = "Notes" })
                      end)
                    end
                  end,
                }
              )
            end,
          })
        end,
      })

    end,
    keys = {
      { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Daily note" },
      { "<leader>om", "<cmd>Obsidian tomorrow<cr>", desc = "Tomorrow's note" },
      { "<leader>oy", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday's note" },
      { "<leader>oD", "<cmd>Obsidian dailies<cr>", desc = "Browse dailies" },
      { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
      { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Find note" },
      { "<leader>of", "<cmd>Obsidian search<cr>", desc = "Search vault" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Links in note" },
      { "<leader>ot", "<cmd>Obsidian tags<cr>", desc = "Tags" },
      { "<leader>oT", "<cmd>Obsidian template<cr>", desc = "Insert template" },
      { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
      { "<leader>oe", "<cmd>Obsidian extract_note<cr>", mode = "v", desc = "Extract to note" },
      { "<leader>oz", function()
        local title = vim.fn.input("Zettel title: ")
        if title ~= "" then
          vim.cmd("Obsidian new zettelkasten/" .. title)
        end
      end, desc = "New zettel" },
      { "<leader>oL", function()
        local title = vim.fn.input("Literature note (author-year-topic): ")
        if title ~= "" then
          vim.cmd("Obsidian new literature/" .. title)
        end
      end, desc = "New literature note" },
      { "<leader>oP", function()
        local function to_kebab(s)
          return s:gsub("(%l)(%u)", "%1-%2"):gsub("(%u+)(%u%l)", "%1-%2")
            :lower():gsub("[^%w]+", "-"):gsub("^-+|-+$", "")
        end

        -- Default to tmux session name in kebab-case
        local session = vim.fn.system("tmux display-message -p '#S'"):gsub("%s+", "")
        local default = (session ~= "" and vim.v.shell_error == 0) and to_kebab(session) or ""
        local name = vim.fn.input("Project name: ", default)
        if name == "" then return end

        local vault = vim.fn.expand("~/notes")
        local dir = vault .. "/projects/" .. name
        vim.fn.mkdir(dir, "p")

        -- Read templates and create files (avoid Obsidian new + template double-frontmatter)
        local tmpl_dir = vault .. "/templates"
        local function create_from_template(tmpl_file, dest, title)
          if vim.fn.filereadable(dest) == 1 then return end
          local lines = vim.fn.readfile(tmpl_dir .. "/" .. tmpl_file)
          for i, line in ipairs(lines) do
            lines[i] = line:gsub("{{title}}", title):gsub("{{date}}", os.date("%Y-%m-%d"))
          end
          vim.fn.writefile(lines, dest)
        end

        create_from_template("project-index.md", dir .. "/index.md", name)
        create_from_template("project-todos.md", dir .. "/todos.md", "Todos")

        -- Open index (obsidian will add frontmatter on save)
        vim.cmd("edit " .. dir .. "/index.md")
      end, desc = "New project note" },
      { "<leader>op", function()
        local vault = vim.fn.expand("~/notes")
        local function normalize(s) return s:lower():gsub("[^%w]", "") end

        -- Try tmux session name first
        local session = vim.fn.system("tmux display-message -p '#S'"):gsub("%s+", "")
        local norm_session = normalize(session)

        -- Search project folders for a normalized match
        local projects = vim.fn.glob(vault .. "/projects/*/", false, true)
        for _, dir in ipairs(projects) do
          local name = dir:match("projects/(.+)/$")
          if name and normalize(name) == norm_session then
            local todos = dir .. "todos.md"
            vim.cmd("edit " .. todos)
            return
          end
        end

        -- Fall back to picker of all project todos
        local files = vim.fn.glob(vault .. "/projects/*/todos.md", false, true)
        if #files == 0 then
          vim.notify("No project todos found", vim.log.levels.WARN)
          return
        end
        local items = {}
        for _, f in ipairs(files) do
          local name = f:match("projects/(.+)/todos%.md$")
          table.insert(items, { name = name, path = f })
        end
        vim.ui.select(items, {
          prompt = "Project todos:",
          format_item = function(item) return item.name end,
        }, function(choice)
          if choice then vim.cmd("edit " .. choice.path) end
        end)
      end, desc = "Project todos" },
    },
  },
}
