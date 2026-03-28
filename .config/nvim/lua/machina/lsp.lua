-- LSP keymaps applied when a language server attaches to a buffer
-- We override some Neovim 0.11+ defaults to keep familiar bindings
local function on_attach(_, bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "K", function()
    vim.lsp.buf.hover { border = "rounded" }
  end, "Hover")
  map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
  map("n", "<C-k>", function()
    vim.lsp.buf.signature_help { border = "rounded" }
  end, "Signature help")
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "List workspace folders")
  map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "gr", vim.lsp.buf.references, "References")
  map("n", "<leader>e", function()
    vim.diagnostic.open_float { source = true }
  end, "Show diagnostics")
  map("n", "[d", function()
    vim.diagnostic.jump { count = -1, float = true }
  end, "Prev diagnostic")
  map("n", "]d", function()
    vim.diagnostic.jump { count = 1, float = true }
  end, "Next diagnostic")
  map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics to loclist")

  -- Inlay hints
  if vim.lsp.inlay_hint then
    map("n", "<leader>ti", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, "Toggle inlay hints")
  end
end

-- Diagnostic icons and display
vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
    },
  },
  virtual_text = true,
  virtual_lines = false,
}

-- Toggle between virtual_text and virtual_lines diagnostics
local function toggle_diagnostic_lines()
  local current = vim.diagnostic.config()
  if current.virtual_lines then
    vim.diagnostic.config { virtual_text = true, virtual_lines = false }
  else
    vim.diagnostic.config { virtual_text = false, virtual_lines = true }
  end
end
vim.keymap.set("n", "<leader>tl", toggle_diagnostic_lines, { desc = "Toggle diagnostic virtual lines" })

-- Apply keymaps to all LSP servers via LspAttach autocmd
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("machina-lsp-attach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    on_attach(client, args.buf)
    if client and (client.name == "ltex" or client.name == "ltex_plus") then
      require("ltex_extra").setup { path = vim.fn.stdpath("data") .. "/ltex" }
    end
  end,
})

-- Servers to install and enable via mason
local servers = {
  "bashls",
  "gopls",
  "ltex_plus",
  "lua_ls",
  "markdown_oxide",
  "ty",
  "sqlls",
  "texlab",
  "yamlls",
  "ruff",
  "vale_ls",
}

require("mason").setup {
  PATH = "append", -- Prefer local binaries where possible
}
require("mason-lspconfig").setup {
  automatic_installation = true,
  ensure_installed = servers,
  automatic_enable = true,
}

-- Per-server settings via vim.lsp.config
vim.lsp.config("ltex_plus", {
  settings = {
    ltex = {
      disabledRules = {
        ["en-US"] = { "TO_DO_HYPHEN" },
      },
      markdown = {
        nodes = {
          TaskListItem = "ignore",
        },
      },
    },
  },
})

vim.lsp.config("texlab", {
  settings = {
    texlab = {
      latexindent = {
        ["local"] = "latexindent.yaml",
      },
    },
  },
})

vim.lsp.config("jsonls", {
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
    },
  },
})

vim.lsp.enable "jsonls"
