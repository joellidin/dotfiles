augroup GopassDetect
    au!
    au BufNewFile,BufRead /dev/shm/gopass-* set filetype=gopass
augroup END
