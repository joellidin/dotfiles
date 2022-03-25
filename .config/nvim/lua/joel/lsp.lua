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
  buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

local function lspSymbol(name, icon)
  vim.fn.sign_define("DiagnosticSign" .. name, { text = icon, numhl = "DiagnosticDefault" .. name })
end
lspSymbol("Error", "")
lspSymbol("Information", "")
lspSymbol("Hint", "")
lspSymbol("Info", "")
lspSymbol("Warning", "")

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local lsp_installer = require "nvim-lsp-installer"

-- Register a handler that will be called for each installed server when it's ready (i.e. when installation is finished
-- or if the server is already installed).
lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
  }

  -- (optional) Customize the options passed to the server
  -- if server.name == "tsserver" then
  --     opts.root_dir = function() ... end
  -- end

  -- This setup() function will take the provided server configuration and decorate it with the necessary properties
  -- before passing it onwards to lspconfig.
  -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  server:setup(opts)
end)

local custom_init = function(client)
  client.config.flags = client.config.flags or {}
  client.config.flags.allow_incremental_sync = true
end

local nvim_lsp = require "lspconfig"
-- local servers = { "pyright", "rust_analyzer", "tsserver", "jsonls" }
-- for _, lsp in pairs(servers) do
--   nvim_lsp[lsp].setup {
--     on_attach = on_attach,
--     flags = {
--       debounce_text_changes = 150,
--     },
--   }
-- end

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
