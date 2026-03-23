:set expandtab
:set tabstop=2
:set shiftwidth=2
:set autoindent
:set wrap
:set linebreak
:set number

:set spellfile=~/.vim/spell/en.utf-8.add

nnoremap <C-p> i```<Esc>o<Esc>o```<Esc>ki
nnoremap z <C-v>
nnoremap <C-f> k/^\d\+\.<CR>gn<C-a>/^\d\+\.<CR>
nnoremap <C-b> j/^\d\+\.<CR>NNgn<C-x>/^\d\+\.<CR>NN
nnoremap <C-q> ciw"<C-r>""<Esc>
