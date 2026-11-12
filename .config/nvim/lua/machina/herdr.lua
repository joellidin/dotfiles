-- Helpers for herdr, the terminal workspace manager that replaced tmux.
-- Used by the worktree hooks (plugins/git.lua) and the notes keymaps (plugins/notes.lua).
local M = {}

-- herdr binary: $HERDR_BIN_PATH when set, else herdr on PATH.
function M.bin()
  local path = vim.env.HERDR_BIN_PATH
  if path and path ~= "" and vim.fn.executable(path) == 1 then return path end
  return "herdr"
end

-- True when this nvim runs inside a herdr pane.
function M.in_herdr()
  local env = vim.env.HERDR_ENV
  return env ~= nil and env ~= ""
end

-- Run `herdr <args...>` and wait up to 5s. Returns the vim.system result, or nil if it could not start.
local function exec(args)
  local ok, res = pcall(function()
    return vim.system(vim.list_extend({ M.bin() }, args), { text = true }):wait(5000)
  end)
  return ok and res or nil
end

-- Run a herdr query and return the `result` table of its JSON output, or nil on any failure.
local function query(args)
  local res = exec(args)
  if not res or res.code ~= 0 then return nil end
  local ok, data = pcall(vim.json.decode, res.stdout or "")
  if not ok or type(data) ~= "table" or type(data.result) ~= "table" then return nil end
  return data.result
end

-- Label of the workspace this nvim runs in, or "" outside herdr or on any error.
function M.current_label()
  if not M.in_herdr() then return "" end
  local cur = query({ "pane", "current" })
  local id = cur and type(cur.pane) == "table" and cur.pane.workspace_id
  if type(id) ~= "string" then return "" end
  local ws = query({ "workspace", "get", id })
  local label = ws and type(ws.workspace) == "table" and ws.workspace.label
  return type(label) == "string" and label or ""
end

-- All workspaces from `herdr workspace list` ({ workspace_id, label, ... }), or {} on error.
function M.workspaces()
  local res = query({ "workspace", "list" })
  return res and type(res.workspaces) == "table" and res.workspaces or {}
end

-- Workspaces whose label is exactly `label` (plain string compare). `list` defaults to M.workspaces().
function M.find_by_label(label, list)
  local found = {}
  for _, ws in ipairs(list or M.workspaces()) do
    if type(ws) == "table" and ws.label == label and type(ws.workspace_id) == "string" then
      table.insert(found, ws)
    end
  end
  return found
end

-- Focus or close a workspace by id. Return true on success.
function M.focus(id)
  local res = exec({ "workspace", "focus", id })
  return res ~= nil and res.code == 0
end

function M.close(id)
  local res = exec({ "workspace", "close", id })
  return res ~= nil and res.code == 0
end

-- Walk up from path to the directory that holds .bare/, if any.
local function find_bare_root(path)
  local dir = path
  while dir and dir ~= "" and dir ~= "/" do
    if vim.fn.isdirectory(dir .. "/.bare") == 1 then return dir end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

-- Workspace label for a directory, the same rule as herdr-sessionizer:
-- "project-branch" inside a bare repo (.bare/), else the basename; dots become underscores.
-- Second return value is the project name inside a bare repo, nil otherwise.
-- Works on the path string alone, so it also works after the directory is removed.
function M.workspace_name(path)
  path = vim.fs.normalize(path)
  local root = find_bare_root(path)
  if root then
    local project = (vim.fs.basename(root):gsub("%.", "_"))
    local rel = (path:sub(#root + 2):gsub("/", "-"):gsub("%.", "_"))
    return project .. "-" .. rel, project
  end
  return (vim.fs.basename(path):gsub("%.", "_")), nil
end

return M
