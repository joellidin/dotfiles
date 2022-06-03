-- Setup nvim-cmp.
local cmp = require "cmp"

local lspkind = require "lspkind"
lspkind.init {
  symbol_map = {
    --     -- Class = '🅒',
    --     Class = '∴',
    --     -- Color = '☀',
    --     -- Color = '⛭',
    --     Color = '🖌',
    --     -- Constant = 'π',
    --     Constant = '𝜋',
    --     Constructor = '⬡',
    --     -- Constructor = '⌬',
    --     -- Constructor = '⎔',
    --     -- Constructor = '⚙',
    --     -- Constructor = 'ᲃ',
    --     Enum = '',
    --     EnumMember = '',
    --     Event = '',
    --     -- Field = '→',
    --     -- Field = '∴',
    --     Field = '🠶',
    --     File = '',
    --     Folder = '',
    --     Function = 'ƒ',
    --     -- Function = 'λ',
    --     Interface = '',
    --     Keyword = '🗝',
    --     Method = '𝘮',
    --     -- Method = 'λ',
    --     Module = '📦',
    --     Operator = '≠',
    --     -- Operator = '±',
    --     -- Property = '::',
    --     Property = '∷',
    --     -- Reference = '⌦',
    --     Reference = '⊷',
    --     -- Reference = '⊶',
    --     -- Reference = '⊸',
    --     -- Snippet = '',
    --     -- Snippet = '↲',
    --     -- Snippet = '♢',
    --     -- Snippet = '<>',
    --     Snippet = '{}',
    Struct = "",
    --     -- Text = '#',
    --     -- Text = '♯',
    --     -- Text = 'ⅵ',
    --     -- Text = "¶",
    --     -- Text = "𝒯",
    --     -- Text = "𝓣",
    --     Text = "𐄗",
    --     TypeParameter = '×',
    --     Unit = '()',
    --     -- Value           =
    --     -- Variable = '𝛼',
    --     -- Variable = 'χ',
    --     Variable = '𝓧',
    --     -- Variable = '𝛸',
    --     -- Variable = 'α',
    --     -- Variable = '≔',
  },
}

cmp.setup {
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    ["<c-y>"] = cmp.mapping(
      cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      },
      { "i", "c" }
    ),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ["<C-Space>"] = cmp.mapping {
      i = cmp.mapping.complete(),
      c = function(
        _ --[[fallback]]
      )
        if cmp.visible() then
          if not cmp.confirm { select = true } then
            return
          end
        else
          cmp.complete()
        end
      end,
    },
  },

  sources = {
    { name = "gh_issues" },
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "luasnip" }, -- For luasnip users.
    { name = "buffer", keyword_length = 5 },
  },

  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
    end,
  },

  formatting = {
    -- Youtube: How to set up nice formatting for your sources.
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[api]",
        path = "[path]",
        luasnip = "[snip]",
        gh_issues = "[issues]",
        tn = "[TabNine]",
      },
    },
  },

  experimental = {
    native_menu = false,
    ghost_text = true,
  },
}

cmp.setup.cmdline("/", {
  completion = {
    -- Might allow this later, but I don't like it right now really.
    -- Although, perhaps if it just triggers w/ @ then we could.
    --
    -- I will have to come back to this.
    autocomplete = false,
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp_document_symbol" },
  }, {
    -- { name = "buffer", keyword_length = 5 },
  }),
})

cmp.setup.cmdline(":", {
  completion = {
    autocomplete = false,
  },

  sources = cmp.config.sources({
    {
      name = "path",
    },
  }, {
    {
      name = "cmdline",
      max_item_count = 20,
      keyword_length = 4,
    },
  }),
})

-- Setup lspconfig.
-- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- require('lspconfig').pyright.setup {
--  capabilities = capabilities
--}
-- nvim-cmp highlight groups.
local Group = require("colorbuddy.group").Group
local g = require("colorbuddy.group").groups
local s = require("colorbuddy.style").styles

Group.new("CmpItemAbbr", g.Comment)
Group.new("CmpItemAbbrDeprecated", g.Error)
Group.new("CmpItemAbbrMatchFuzzy", g.CmpItemAbbr.fg:dark(), nil, s.italic)
Group.new("CmpItemKind", g.Special)
Group.new("CmpItemMenu", g.NonText)
