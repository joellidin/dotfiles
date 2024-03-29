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
    -- { name = "gh_issues" },
    { name = "git" },
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "luasnip" }, -- For luasnip users.
    { name = "buffer", keyword_length = 5 },
    { name = "crates" },
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
        git = "[git]",
        tn = "[TabNine]",
        crates = "[crates]",
      },
    },
  },

  experimental = {
    native_menu = false,
    ghost_text = true,
  },
}

require("cmp_git").setup {
  filetypes = { "gitcommit", "octo", "markdown" },
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
