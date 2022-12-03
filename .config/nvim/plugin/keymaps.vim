inoremap <Up>     <C-o>:echom "--> k <-- "<CR>
inoremap <Down>   <C-o>:echom "--> j <-- "<CR>
inoremap <Right>  <C-o>:echom "--> l <-- "<CR>
inoremap <Left>   <C-o>:echom "--> h <-- "<CR>


" Helpful delete/change into blackhole buffer
nmap <leader>d "_d
nmap <leader>c "_c
nmap <leader>d "_d
nmap <leader>c "_c

" Opens line below or above the current line
inoremap <S-CR> <C-O>o
inoremap <C-CR> <C-O>O

nnoremap j <cmd>call tj#jump_direction('j')<CR>
nnoremap k <cmd>call tj#jump_direction('k')<CR>

" Execute this file
nnoremap <leader><leader>x :call tj#save_and_exec()<CR>

" Make esc leave terminal mode
tnoremap <leader><Esc> <C-\><C-n>
tnoremap <Esc><Esc> <C-\><C-n>

" Tips from ThePrimeagen
" replace currently selected text with default register
" without yanking it
xnoremap <leader>p "_dP

nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z

vnoremap J :move '>+1<CR>gv=gv
vnoremap K :move '<-2<CR>gv=gv

nnoremap ]q :cnext<CR>
nnoremap [q :cprev<CR>

" Good for swedish keyboard
nnoremap Ö :

nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
