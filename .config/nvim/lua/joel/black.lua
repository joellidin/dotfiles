local Path = require "plenary.path"
local Job = require "plenary.job"

local lspconfig_util = require "lspconfig.util"

local cached_configs = {}

local root_finder = lspconfig_util.root_pattern ".git"
local black_finder = function(path)
  if cached_configs[path] == nil then
    local file_path = Path:new(path)
    local root_path = Path:new(root_finder(path))

    local file_parents = file_path:parents()
    local root_parents = root_path:parents()

    local relative_diff = #file_parents - #root_parents
    for index, dir in ipairs(file_parents) do
      if index > relative_diff then
        break
      end

      local black_path = Path:new { dir, "pyproject.toml" }
      if black_path:exists() then
        cached_configs[path] = black_path:absolute()
        break
      end

      black_path = Path:new { dir, ".pyproject.toml" }
      if black_path:exists() then
        cached_configs[path] = black_path:absolute()
        break
      end
    end
  end

  return cached_configs[path]
end

local black = {}

black.format = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local filepath = Path:new(vim.api.nvim_buf_get_name(bufnr)):absolute()
  local pyproject_toml = black_finder(filepath)

  local j
  if not pyproject_toml then
    j = Job:new {
      "black",
      "--line-length",
      100,
      "-",
      writer = vim.api.nvim_buf_get_lines(0, 0, -1, false),
    }
  else
    j = Job:new {
      "black",
      "--config",
      pyproject_toml,
      "-",
      writer = vim.api.nvim_buf_get_lines(0, 0, -1, false),
    }
  end

  local output = j:sync()

  if j.code ~= 0 then
    -- Schedule this so that it doesn't do dumb stuff like printing two things.
    vim.schedule(function()
      print "[black] Failed to process due to errors"
    end)

    return
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
  pcall(vim.api.nvim_buf_clear_namespace, bufnr, Luasnip_ns_id, 0, -1)

  -- Handle some weird snippet problems. Not everyone will necessarily have this problem.
  Luasnip_current_nodes = Luasnip_current_nodes or {}
  Luasnip_current_nodes[bufnr] = nil
end

return black
