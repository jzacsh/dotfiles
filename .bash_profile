#colors:
col_red='\[\e[1;31m\]'
col_grn='\[\e[1;32m\]'
col_blu='\[\e[1;34m\]'
col_end='\[\e[m\]'
#

# progs
export EDITOR=vim
export DIFF=' up '
export LESS=' XFRr '
export RLWRAP=' AaN '
export PAGER=less
export CDPATH=.:~/down/
 PATH=.:$HOME/bin:$HOME/bin/local:$HOME/bin/share:$HOME/bin/lib:$HOME/bin/dist:/srv/http/global/bin/dev/:$PATH
export PATH
export PYTHONDOCS=/usr/share/doc/python/html/
export PYTHONPATH=$HOME/bin/lib/python:/usr/lib/python3.1/
export PYTHONVER=3
export PYTHONSTARTUP=$HOME/.pythonrc.py
export RUBYOPT='w' #helpful ruby warnings
export GREP_OPTIONS='--color=auto'
export CLASSPATH=.:$CLASSPATH
export CSCOPE_DB=$HOME/.vim/cscope.out
export COWER='cower --color=auto'
export BROWSER=w3m
#

#make sure dropbox is running
if [[ $(type -p dropbox &> /dev/null) ]];then
    pidof dropbox &> /dev/null || dropbox start >/dev/null & disown
fi

#if interactive, source .bashrc
[[ -n $PS1 && -f ~/.bashrc ]] && source ~/.bashrc
