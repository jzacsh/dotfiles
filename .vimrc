"this is vim's rc
" comments in double-quotes (`"')
" awesome reference:    http://amix.dk/vim/vimrc.html

" more awesome reference:    http://learnvimscriptthehardway.stevelosh.com

let $VIM = $HOME ."/.vim/"

"variables
"-----------------------
let maplocalleader = ","

"keymapping
"-----------------------
map <LocalLeader>h  :GundoToggle<CR>
map <LocalLeader>b  :VCSBlame<CR>
map <LocalLeader>r  :MRU<CR>
map <LocalLeader>R  :!./%<CR>
map <LocalLeader>p  :se invpaste paste?<return>
map <LocalLeader>s  :r!date --rfc-3339=seconds<CR>
map <LocalLeader>f  :TlistToggle<CR>
map <LocalLeader>t  :CommandT<CR>
map <LocalLeader>T  $a //@TODO: remove me!!    <Esc>0
" clear trailing whitespace
map <LocalLeader>c  :%s/[[:space:]]*$//g<CR>
map <LocalLeader>C  :%s/^[[:space:]]*$//g<CR>
map <LocalLeader>n  :!node %<CR>
"listing of buffers
map <LocalLeader>l  :ls<CR>

"binding for VimRoom plugin
map <LocalLeader>v :VimroomToggle<CR>

" easy tab handling
map <LocalLeader>w  :tabnew<CR>
map <LocalLeader>1  1gt
map <LocalLeader>2  2gt
map <LocalLeader>3  3gt
map <LocalLeader>4  4gt
map <LocalLeader>5  5gt
map <LocalLeader>6  6gt
map <LocalLeader>7  7gt
map <LocalLeader>8  8gt
map <LocalLeader>9  9gt
" no need to 'q:' anymore
nnoremap ; :

"last position in file, see :help last-position-jump
:au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

"vim 7.3-specific
if v:version >= 730
   set colorcolumn=+1,+2,+3
endif


set cmdheight=2

set wildmode=longest,list

"pathogen magic:
call pathogen#infect($VIM."bundle/")

"color schemes
"-----------------------
" colorscheme ir_black
" colorscheme merged
" colorscheme mustang
" colorscheme dante

" from http://vimcolorschemetest.googlecode.com/svn/html/index-c.html
" colorscheme desert
" colorscheme darkZ
" colorscheme graywh
" colorscheme jellybeans
" colorscheme molokai
" colorscheme skittles_dark
colorscheme anotherdark

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

" default spaces in tabs/indents:
set ts=2
set sw=2

"drupal.org suggestions:
if has("autocmd")
  " Drupal *.module and *.install files.
  augroup drupal
    autocmd!
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
"@TODO drupal files - i can't refer to augroup 'drupal'?
"  ? autocmd augroup drupal set ts=2
"js
autocmd FileType js set ts=2
autocmd FileType js set sw=2
autocmd FileType js set sts=2
"php
autocmd FileType php set ts=2
autocmd FileType php set sw=2
autocmd FileType php set sts=2
"python
autocmd FileType py set ts=4
autocmd FileType py set sw=4
autocmd FileType py set sts=4

"lesscss.org
au BufNewFile,BufRead *.less set filetype=less
"haml-lang.org
au! BufRead,BufNewFile *.haml set filetype haml

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
set statusline=%t%(\ [%n%M]%)%(\ %H%R%W%)\ %(%c-%v,\ %l\ of\ %L,\ (%o)\ %P\ 0x%B\ (%b)%)
" set statusline+={rvm#statusline()}
set hidden " not sure what this does.

"set mouse=a    "annoying

"plugin specific stuff:
"let MRU_File = "$VIM/plugin/mru.vim"
let MRU_Exclude_Files = '$HOME/tmp/.*'
let MRU_Auto_Close = 0
let MRU_Max_Entries = 10

" When we're in X11
if &term !=# "linux"
    set background=dark
    set list listchars=tab:\»\ ,extends:›,precedes:‹
endif

"highlight redundant whitespace.
highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t\|\t/

"xdebug in vim
let g:debuggerPort = 9000

" vimroom
let g:vimroom_width = 88

" ledger-cli.org
au BufNewFile,BufRead *.ldg,*.ledger setf ledger | comp ledger

set modeline
