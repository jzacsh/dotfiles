autocmd!
let $VIM = $HOME ."/.vim/"

" per output from `opam install otp-indent`
set rtp^=~/.opam/system/share/ocp-indent/vim

let mapleader = ","
let maplocalleader = "\\"



"
" General settings & configuration
""""""""""""""""""""""""""""""""""

set cmdheight=2
set wildmode=longest,list
set foldlevel=3

set nolist eol

" set which wraps
set whichwrap+=<,>,h,l

" for filetype event-based configs
filetype plugin on
filetype indent on

" read in live edits on opened files
set autoread

" show results while typing
set incsearch
" pfftt.. who needs the real vi anyway?
set nocompatible

" textwidth:
set tw=80

" always showtab:
set showtabline=2

" spaces for tabs: `expandtab'
set et

" default spaces in tabs/indents:
set ts=2
set sw=2

" syntax hilighting
syntax on
set ff=unix
set autoindent
set history=400
set ruler
set number
set laststatus=2
set statusline=%t%(\ [buf:\ %n%M]%)%(\ %H%R%W%)\ %L\ lines\ \|\ scroll:\ %P\ \|\ [cursor]\ %(col:\ %c,\ byte:\ #%o,\ val:\ %b=0x%B%)
set hidden

" too annoying:
""""""""""""""
" enables mouse for any of mode:
"   [n]ormal,[v]isual,[i]nsert,[c]ommandline,[h]elp-file,[a]ll
"set mouse=i

" for some reason nvim *still* scrolls w/trackpad
"   last resort, per http://unix.stackexchange.com/a/44516
autocmd BufEnter * set mouse=


" color schemes
"   from http://vimcolorschemetest.googlecode.com/svn/html/index-c.html
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"robust against funky terminal background colors
"" Rating from good to bad:    :(    :/    :)
"
" dante  " :/ really light/bright symbols
" skittles_dark   " :/ can't tell my strings from my objects
" anotherdark   " :( ... not enough contrast
" wombat  " :)
"colorscheme desert  " :) ... favorite; ==~ darkZ
" darkZ

" current favorite: "slate" and "ron"
colorscheme slate

" must be after colorscheme
set cursorline
hi  cursorline   cterm=none
hi  cursorlinenr term=bold ctermfg=white

"" EXPERIMENTAL:
" freya
" Tomorrow-Night-Eighties
" jellybeans
" " specific to 'jellybeans':
" " highlight LineNr ctermfg=grey ctermbg=black
" hornet
" graywh
" mustang " no cursor
" freya
" tir_black




"
" Advanced/Quirky settings & configuration
""""""""""""""""""""""""""""""""""""""""""

" When we're in X11
if v:version >= 704
  if &term !=# "linux"
    " set background=dark
    set list listchars=tab:\»\ ,extends:›,precedes:‹
  endif
endif

" always jump to last position in file, see :help last-position-jump
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

"highlight redundant whitespace.
highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t\|\t/

function! HighlightTooLongLines()
  highlight def link RightMargin Error
  if &textwidth != 0
    exec 'match RightMargin /\%<' . (&textwidth + 3) . 'v.\%>' . (&textwidth + 1) . 'v/'
  endif
endfunction
augroup setup_too_long_line_highlighting
  autocmd CursorMoved,FileType,BufEnter * call HighlightTooLongLines()
augroup END
if v:version >= 703
  " creates *constant* long-line marker with columns color
  " set colorcolumn=+1,+2,+3

  augroup color_tweak
    autocmd!
    autocmd ColorScheme * highlight clear ColorColumn
    autocmd ColorScheme * highlight ColorColumn guifg=red ctermfg=red gui=bold
  augroup END
endif




"
" Language-specific settings
" TODO(jzacsh) aren't these handled by syntax files? maybe delete all of this?
""""""""""""""""""""""""""
if has("autocmd")
  " make files
  autocmd FileType make set noexpandtab

  "js
  autocmd FileType js set ts=2
  autocmd FileType js set sw=2
  autocmd FileType js set sts=2

  "php
  autocmd FileType php set ts=2
  autocmd FileType php set sw=2
  autocmd FileType php set sts=2

  "python
  autocmd FileType py set ts=2
  autocmd FileType py set sw=2
  autocmd FileType py set sts=2

  " ... but different width when reading mail
  autocmd BufRead ~/tmp/mutt-* set tw=72
  autocmd FileType java set tw=100

  " lesscss.org
  au BufNewFile,BufRead *.less set filetype less

  " haml-lang.org
  au! BufRead,BufNewFile *.haml set filetype haml

  " ledger-cli.org
  au BufNewFile,BufRead *.ldg,*.ledger setf ledger | comp ledger

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




"
" Jon's custom vimscript functions
""""""""""""""""""""""""""""""""""


" Append some annotation reminding you a particular line or set of lines are
" for debugging only and should not be committed to your VCS.
function! AppendDoNotSubmit()
  " Add mark
  normal! mx

  " Append comment to current line
  normal! A  DO NOT SUBMIT
  normal! bhbhbh
  call NERDComment('n', 'toEOL')

  "Go back to mark
  normal! 'x
endfunction



"
" Keymappings for jon's plain-old-vimisms
"""""""""""""""""""""""""""""""""""""""""

" toggle :set (no)paste
nnoremap <Leader>P  :se invpaste paste?<return>

" search directories - blows my mind; no idea how to use
" nnoremap <Leader>d  :FufDir<CR>
nnoremap <Leader>f  :find<Space>

" execute this file's contents
nnoremap <Leader>R  :!./%<CR>

" timestamp
nnoremap <Leader>S  :r!date --rfc-3339=seconds<CR>

" clear trailing whitespace
nnoremap <Leader>c  :%s/[[:space:]]*$//g<CR>

" quickly append notes to catch printf/debugging code
nnoremap <Leader>T  :call AppendDoNotSubmit()<return>

" buffer list
nnoremap <Leader>b  :ls<CR>:buffer<Space>
" buffer close [x] button
nnoremap <Leader>x  :bd<CR>
" buffer next
nnoremap <Leader>p  :bnext<CR>
" buffer previous
nnoremap <Leader>n  :bprevious<CR>

" no need to 'q:' anymore
nnoremap ; :
" no need to 'q:![shell stuff]' anymore, just ![shell stuff]
nnoremap ! :!



"
" Keymappings for Tools & Plugins
""""""""""""""""""""""""""""""""""""""""""""""

" [h]istory true
nnoremap <Leader>h  :GundoToggle<CR>
nnoremap <Leader>r  :MRU<CR>
" [v]ariables in this file
nnoremap <Leader>v  :TlistToggle<CR>
" [w]riting mode: binding for VimRoom plugin
nnoremap <Leader>w :VimroomToggle<CR>



"
" Settings for Tools & Plugins
""""""""""""""""""""""""""""""""""""""""""""""
"let MRU_File = "$VIM/plugin/mru.vim"
let MRU_Exclude_Files = '$HOME/tmp/.*'
let MRU_Auto_Close = 0
let MRU_Max_Entries = 10

" syntastic:
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
let g:syntastic_auto_loc_list = 1
"let g:syntastic_c_checkers = ['clang-3.6']
let g:syntastic_cpp_checkers = ['clang-check-3.6']
let g:syntastic_cpp_compiler = 'clang-3.6'
let g:syntastic_cpp_compiler_options = '-std=c++11 '
let g:syntastic_css_checkers = ['prettycss']
let g:syntastic_html_checkers = ['jshint']
let g:syntastic_javascript_checkers = ['gjslint']
let g:syntastic_java_checkers = ['javac']
let g:syntastic_java_javac_config_file_enabled = 1
let g:syntastic_debug_file = '~/usr/log/syntastic.log'

" disable syntastic for bats, but not syntax; *sort* of per:
"    https://groups.google.com/d/msg/vim-syntastic/D80n65Fgj1w/y5OIJUQWY4wJ
let g:syntastic_mode_map = {'mode': 'active', 'passive_filetypes': ['bats', 'java']}


" xdebug
let g:debuggerPort = 9000

" vimroom
let g:vimroom_width = 88

let php_sql_query = 1
let php_baselib = 1
let php_htmlInStrings = 1
let php_oldStyle = 1
let php_parent_error_close = 1
let php_parent_error_open = 1
let php_folding = 1
let php_sync_method = 0

" pathogen magic:
call pathogen#infect($VIM."bundle/{}")

" vim rainbow_parenthesis: github.com/kien/rainbow_parentheses.vim
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces


" highlight variable on hover stackoverflow.com/questions/1551231
" NOTE: inorder to work, this *must* come after RainbowParentheses plugin conf
autocmd CursorMoved * exe printf('match Visual /\V\<%s\>/', escape(expand('<cword>'), '/\'))

set modeline

" open by default
autocmd VimEnter,FileType java NERDTree
