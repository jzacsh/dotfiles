for key  in ~/.ssh/add/*.add ; do
  keychain --quiet --timeout 240 $key # 4 hours
done
unset key
source ~/.keychain/$HOSTNAME-sh
# to load keys on this machine setup in ~/.ssh/add/:
# lrwxrwxrwx   jzlut.add -> ../jzlut
# lrwxrwxrwx   jzlut.add.pub -> ../jzlut.pub

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
export PAGER=less
export CDPATH=.:~/down/
 PATH=.:$HOME/bin:$HOME/bin/local:$HOME/bin/share:$HOME/bin/dist:$PATH
 PATH=$PATH:/opt/java/jre/bin/:/srv/http/global/bin/dev/
export PATH

export PYTHONDOCS=/usr/share/doc/python/html/
export RUBYOPT='w' #helpful ruby warnings
export GREP_OPTIONS='--color=auto'
export CLASSPATH=.:$CLASSPATH
export CSCOPE_DB=$HOME/.vim/cscope.out
export COWER='cower --color=auto'
export BROWSER=w3m
#

pidof dropbox &> /dev/null || ~/bin/dist/dropbox start

#if interactive, source .bashrc
[[ -n $PS1 && -f ~/.bashrc ]] && source ~/.bashrc
