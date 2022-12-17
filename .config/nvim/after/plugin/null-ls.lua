local has_null_ls, null_ls = pcall(require, "null-ls")
if not has_null_ls then
  return
end
local methods = require "null-ls.methods"
local helpers = require "null-ls.helpers"

local function ruff_fix()
  return helpers.make_builtin {
    name = "ruff",
    meta = {
      url = "https://github.com/charliermarsh/ruff/",
      description = "An extremely fast Python linter, written in Rust.",
    },
    method = methods.internal.FORMATTING,
    filetypes = { "python" },
    generator_opts = {
      command = "ruff",
      args = { "--fix", "-e", "-n", "--stdin-filename", "$FILENAME", "-" },
      to_stdin = true,
    },
    factory = helpers.formatter_factory,
  }
end

null_ls.setup {
  sources = {
    ruff_fix(),
    null_ls.builtins.diagnostics.ruff,
    -- null_ls.builtins.diagnostics.flake8,
  },
}
