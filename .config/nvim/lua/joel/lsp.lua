-- local lsp = require'lspconfig'

-- lsp.diagnosticls.setup {
--   filetypes = {"python"},
--  init_options = {
--    formatters = {
--      black = {
--        command = "black",
--        args = {"--quiet", "-"},
--        rootPatterns = {"pyproject.toml"},
--      },
--      formatFiletypes = {
--        python = {"black"}
--      }
--    }
--  }
-- }
-- lsp.pyright.setup{
--   settings = {
--     python = {
--       linting = {
--         flake8Enabled = true,
--         enabled = true,
--         flake8Args = {"--config=/Users/joellidin/Documents/matched-betting/setup.cfg"},
--       },
--       formatting = {
--         provider = "black",
--         blackArgs = {"--config", "/Users/joellidin/Documents/matched-betting/pyproject.toml"},
--       }
--     }
--   }
-- }
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Mappings.
  local opts = { noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
  buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  buf_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
  buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format { async = true }<CR>", opts)
end

local function lspSymbol(name, icon)
  vim.fn.sign_define("DiagnosticSign" .. name, { text = icon, numhl = "DiagnosticDefault" .. name })
end
lspSymbol("Error", "???")
lspSymbol("Information", "???")
lspSymbol("Hint", "???")
lspSymbol("Info", "???")
lspSymbol("Warning", "???")

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches

-- Default servers to install from LSP installer
local servers = {
  "bashls",
  "pyright",
  "sqlls",
  "gopls",
  "yamlls",
  "rust_analyzer",
}

-- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
-- or if the server is already installed).

local custom_init = function(client)
  client.config.flags = client.config.flags or {}
  client.config.flags.allow_incremental_sync = true
end

require("nvim-lsp-installer").setup {
  automatic_installation = true,
}
local nvim_lsp = require "lspconfig"
for _, lsp in pairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
  }
end

-- setup for flake8
-- local flake8 = {
--   lintCommand = "flake8 --stdin-display-name ${INPUT} -",
--   lintStdin = true,
--   lintFormats = { "%f=%l:%c: %m" },
-- }
-- require("lspconfig").efm.setup {
--   init_options = { documentFormatting = true },
--   settings = {
--     rootMarkers = { ".git/" },
--     languages = {
--       python = {
--         { flake8 },
--       },
--     },
--   },
--   filetypes = { "python" },
--   on_attach = on_attach,
-- }

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require("lspconfig").jsonls.setup {
  capabilities = capabilities,
}

-- Lua lsp
_ = require("nlua.lsp.nvim").setup(nvim_lsp, {
  on_init = custom_init,
  on_attach = on_attach,
  capabilities = capabilities,

  globals = {
    -- Colorbuddy
    "Color",
    "c",
    "Group",
    "g",
    "s",

    -- Custom
    "RELOAD",
  },
})

local function filter(arr, func)
  -- Filter in place
  -- https://stackoverflow.com/questions/49709998/how-to-filter-a-lua-array-inplace
  local new_index = 1
  local size_orig = #arr
  for old_index, v in ipairs(arr) do
    if func(v, old_index) then
      arr[new_index] = v
      new_index = new_index + 1
    end
  end
  for i = new_index, size_orig do
    arr[i] = nil
  end
end

local function filter_diagnostics(diagnostic)
  -- Only filter out Pyright stuff for now
  if diagnostic.source ~= "Pyright" then
    return true
  end

  -- Allow kwargs to be unused, sometimes you want many functions to take the
  -- same arguments but you don't use all the arguments in all the functions,
  -- so kwargs is used to suck up all the extras
  if diagnostic.message == '"kwargs" is not accessed' then
    return false
  end

  -- Allow variables starting with an underscore
  if string.match(diagnostic.message, '"_.+" is not accessed') then
    return false
  end

  return true
end

local function custom_on_publish_diagnostics(a, params, client_id, c, config)
  filter(params.diagnostics, filter_diagnostics)
  vim.lsp.diagnostic.on_publish_diagnostics(a, params, client_id, c, config)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(custom_on_publish_diagnostics, {})
