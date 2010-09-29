" this is vim's rc
" comments in double-quotes (`"')
" awesome reference:		http://amix.dk/vim/vimrc.html

"variables
"-----------------------
let maplocalleader = ","

"keymapping
"-----------------------
map <LocalLeader>t  <Esc>:tabnew<CR>
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

set background=dark
colorscheme zellner

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

" always showtab:
set showtabline=2

" spaces for tabs:
" `expandtab'
set et

" 4 spaces in tabs:
set ts=2
set sw=2

" xdebug port
let g:debuggerPort = 9001

" make files
autocmd FileType make set noexpandtab

"drupal.org suggestions:
if has("autocmd")
  " Drupal *.module and *.install files.
  augroup module
    autocmd BufRead,BufNewFile *.module set filetype=php
    autocmd BufRead,BufNewFile *.install set filetype=php
    autocmd BufRead,BufNewFile *.admin.inc set filetype=php
    autocmd BufRead,BufNewFile *.test set filetype=php
  augroup END
endif
syntax on

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


"xdebug in vim
let g:debuggerPort = 9000
