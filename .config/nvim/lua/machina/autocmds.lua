local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text briefly
autocmd("TextYankPost", {
  group = augroup("machina-yank-highlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "Substitute", timeout = 150, on_macro = true })
  end,
})

-- Smart relative number toggle
local number_toggle = augroup("machina-number-toggle", { clear = true })
autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = number_toggle,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = true
    end
  end,
})
autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = number_toggle,
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
    end
  end,
})

-- Restore cursor position on file open
autocmd("BufReadPost", {
  group = augroup("machina-restore-cursor", { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("machina-trim-whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- Auto-resize splits on window resize
autocmd("VimResized", {
  group = augroup("machina-resize-splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Dim inactive windows using highlight namespaces (transparent-friendly)
-- TODO: re-enable once compatible with snacks picker and floating windows
-- local win_focus = augroup("machina-win-focus", { clear = true })
-- local dim_ns = vim.api.nvim_create_namespace("machina-dim")
-- local dim_factor = 0.65
--
-- local function dim_fg(color)
--   local r = math.floor(bit.rshift(bit.band(color, 0xFF0000), 16) * dim_factor)
--   local g = math.floor(bit.rshift(bit.band(color, 0x00FF00), 8) * dim_factor)
--   local b = math.floor(bit.band(color, 0x0000FF) * dim_factor)
--   return bit.bor(bit.lshift(r, 16), bit.lshift(g, 8), b)
-- end
--
-- local function build_dim_highlights()
--   for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
--     local dimmed = vim.deepcopy(hl)
--     if dimmed.fg then dimmed.fg = dim_fg(dimmed.fg) end
--     if dimmed.sp then dimmed.sp = dim_fg(dimmed.sp) end
--     pcall(vim.api.nvim_set_hl, dim_ns, name, dimmed)
--   end
-- end
--
-- build_dim_highlights()
--
-- autocmd("ColorScheme", {
--   group = win_focus,
--   callback = build_dim_highlights,
-- })
-- autocmd({ "WinEnter", "BufWinEnter" }, {
--   group = win_focus,
--   callback = function()
--     vim.api.nvim_win_set_hl_ns(0, 0)
--   end,
-- })
-- autocmd("WinLeave", {
--   group = win_focus,
--   callback = function()
--     vim.api.nvim_win_set_hl_ns(0, dim_ns)
--   end,
-- })

-- Obsidian vault: disable swap and auto-reload changes from other instances
local obsidian_vault = augroup("machina-obsidian-vault", { clear = true })
autocmd("BufEnter", {
  group = obsidian_vault,
  pattern = vim.fn.expand("~/notes") .. "/**/*.md",
  callback = function()
    vim.opt_local.swapfile = false
    vim.opt_local.autoread = true
  end,
})
autocmd("FocusGained", {
  group = obsidian_vault,
  pattern = vim.fn.expand("~/notes") .. "/**/*.md",
  callback = function()
    vim.cmd("checktime")
  end,
})

-- Close certain buffer types with q
autocmd("FileType", {
  group = augroup("machina-close-with-q", { clear = true }),
  pattern = { "help", "man", "qf", "lspinfo", "notify", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto-create parent directories on save
autocmd("BufWritePre", {
  group = augroup("machina-auto-mkdir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- LSP progress via snacks.notifier (replaces fidget.nvim)
---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
local progress = vim.defaulttable()
autocmd("LspProgress", {
  group = augroup("machina-lsp-progress", { clear = true }),
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
    if not client or type(value) ~= "table" then return end
    local p = progress[client.id]

    for i = 1, #p + 1 do
      if i == #p + 1 or p[i].token == ev.data.params.token then
        p[i] = {
          token = ev.data.params.token,
          msg = ("[%3d%%] %s%s"):format(
            value.kind == "end" and 100 or value.percentage or 100,
            value.title or "",
            value.message and (" **%s**"):format(value.message) or ""
          ),
          done = value.kind == "end",
        }
        break
      end
    end

    local msg = {} ---@type string[]
    progress[client.id] = vim.tbl_filter(function(v)
      return table.insert(msg, v.msg) or not v.done
    end, p)

    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    vim.notify(table.concat(msg, "\n"), "info", {
      id = "lsp_progress",
      title = client.name,
      opts = function(notif)
        notif.icon = #progress[client.id] == 0 and " "
          or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      end,
    })
  end,
})

-- Clean up terminal buffers (no line numbers, no scrolloff)
autocmd("TermOpen", {
  group = augroup("machina-terminal", { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 0
  end,
})
