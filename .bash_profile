
pidof dropboxd &> /dev/null || ~/bin/dropbox start

keychain /home/jzacsh/.ssh/add/*.add
source ~/.keychain/$HOSTNAME-sh

#colors:
col_red='\[\e[1;31m\]'
col_grn='\[\e[1;32m\]'
col_blu='\[\e[1;34m\]'
col_end='\[\e[m\]'
#

# progs
export EDITOR=vim
export LESS=' -XFRr '
export BROWSER=firefox
export GREP_OPTIONS='--color=auto'
export CDPATH=$CDPATH:.:~
export CSCOPE_DB=$HOME/.vim/cscope.out

#if interactive, source .bashrc
[[ -n $PS1 && -f ~/.bashrc ]] && source ~/.bashrc
