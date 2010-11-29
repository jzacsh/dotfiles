" this is vim's rc
" comments in double-quotes (`"')
" awesome reference:		http://amix.dk/vim/vimrc.html

let $VIM = '$HOME/.vim'

"variables
"-----------------------
let maplocalleader = ","

"keymapping
"-----------------------
map <LocalLeader>g  <Esc>:set paste<CR>
map <LocalLeader>G  <Esc>:set nopaste<CR>
map <LocalLeader>r  <Esc>:MRU<CR>
map <LocalLeader>s  <Esc>:r!date --rfc-3339=seconds<CR>
map <LocalLeader>d  <Esc>:r!date --rfc-3339=date<CR>
map <LocalLeader>f  <Esc>:TlistToggle<CR>
map <LocalLeader>t  <Esc>:tabnew<CR>
map <LocalLeader>n  <Esc>:tabnext<CR>
map <LocalLeader>N  <Esc>:tabprevious<CR>
map <LocalLeader>1  1gt
map <LocalLeader>2  2gt
map <LocalLeader>3  3gt
map <LocalLeader>4  4gt
map <LocalLeader>5  5gt
map <LocalLeader>6  6gt
map <LocalLeader>7  7gt
map <LocalLeader>8  8gt
map <LocalLeader>9  9gt

set cmdheight=2

" set background=dark
  colorscheme ir_black
" colorscheme merged
" colorscheme dante

" set which wraps
set whichwrap+=<,>,h,l

" for filetype event-based configs
filetype plugin on
filetype indent on

"read in live edits on opened files
set autoread

" vim's extra set of commands
" are incompatible with vi
set nocompatible

" show results while typing
set incsearch

" textwidth:
set tw=79
au BufRead ~/tmp/mutt-* set tw=72

" always showtab:
set showtabline=2

" spaces for tabs:
" `expandtab'
set et

" 4 spaces in tabs:
set ts=4
set sw=2

" xdebug port
let g:debuggerPort = 9001

"drupal.org suggestions:
if has("autocmd")
  " Drupal *.module and *.install files.
  augroup drupal
    autocmd BufRead,BufNewFile *.php set filetype=php
    autocmd BufRead,BufNewFile *.module set filetype=php
    autocmd BufRead,BufNewFile *.install set filetype=php
    autocmd BufRead,BufNewFile *.theme.inc set filetype=php
    autocmd BufRead,BufNewFile *.theme set filetype=php
    autocmd BufRead,BufNewFile *.admin.inc set filetype=php
    autocmd BufRead,BufNewFile *.test set filetype=php
  augroup END
endif

" make files
autocmd FileType make set noexpandtab
" drupal files - i can't refer to augroup 'drupal'?
autocmd FileType php set ts=2
autocmd FileType js set ts=2
autocmd FileType php set sw=2

" syntax hilighting
syntax on

" causes xdebug to insert on <F12>; too annoying:
" set omnifunc=phpcomplete#CompletePHP
" imap <buffer> <C-d> <C-\><C-O>:call drupal6complete#Map()<CR><C-X><C-O>

let php_sql_query = 1
let php_baselib = 1
let php_htmlInStrings = 1
let php_oldStyle = 1
let php_parent_error_close = 1
let php_parent_error_open = 1
let php_folding =1
let php_sync_method = 0

set ff=unix
set autoindent
set ai
set history=400
set nosi
set ruler
set number
set laststatus=2
" set mouse=a	"annoying

"plugin specific stuff:
"let MRU_File = "$VIM/plugin/mru.vim"
let MRU_Exclude_Files = '$HOME/tmp/.*'
let MRU_Auto_Close = 0
let MRU_Max_Entries = 10

"xdebug in vim
let g:debuggerPort = 9000
