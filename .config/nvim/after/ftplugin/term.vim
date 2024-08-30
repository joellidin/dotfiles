setlocal norelativenumber
setlocal nonumber

setlocal scrolloff=0


tnoremap ,reload %load_ext autoreload<CR>%autoreload 2<CR>
lua << EOF
  -- require "notify" "LOADED TERMINAL FTPLUGIN"
EOF
