" per https://neovim.io/doc/user/nvim.html#nvim-from-vim
"    as of https://github.com/neovim/neovim/tree/da99ded25bf49
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
