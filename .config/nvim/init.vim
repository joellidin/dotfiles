if has('nvim-0.6')
  runtime! packer/packer_compiled.vim
  lua require 'joel.setup'
else
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
endif
