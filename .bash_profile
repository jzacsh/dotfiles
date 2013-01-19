#!/usr/bin/env bash

#make sure dropbox is running
if [[ $(type -p dropbox &> /dev/null) ]];then
    pidof dropbox &> /dev/null || dropbox start >/dev/null & disown
fi

#make sure irssi's notify.pl knows dbus address
if [[ -n $DBUS_SESSION_BUS_ADDRESS ]];then
    echo "$DBUS_SESSION_BUS_ADDRESS" > ~/.dbus_address
fi

export EDITOR=vim
export DIFF=' up '
export LESS=' XFRr '
export RLWRAP=' AaN '
export PAGER=less
 PATH=$HOME/bin:$HOME/bin/local:$HOME/bin/share:$HOME/bin/dist:$HOME/bin/lib:/srv/http/global/bin/dev/:$HOME/usr/local/bin/androidsdk/platform-tools:$HOME/usr/local/bin/androidsdk/tools:$PATH
export PATH
export RUBYOPT='w' #helpful ruby warnings
export GREP_OPTIONS='--color=auto'
export CLASSPATH=$HOME/var/edu/princenton/algs4/:$CLASSPATH
export CSCOPE_DB=$HOME/.vim/cscope.out
export COWER='cower --color=auto'
export BROWSER=w3m
export SHOT_PUB='shot'
export SHOT_UPLOAD='ompload'
export PYTHONPATH="$HOME/usr/lib/python/${PYTHONPATH:+":$PYTHONPATH"}"
export TTS_CONFIG=~/.ttskeyrc
export NODE_PATH="/usr/lib/node_modules/:/usr/lib/node/:$NODE_PATH"
export PASTIE='dpaste'

#if interactive, source .bashrc
[[ -n $PS1 && -f ~/.bashrc ]] && source ~/.bashrc

# vim: et:ts=4:sw=4
