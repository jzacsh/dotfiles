#!/usr/bin/env bash

#make sure dropbox is running
if [[ $(type -p dropbox &> /dev/null) ]];then
    pidof dropbox &> /dev/null || dropbox start >/dev/null & disown
fi

#make sure irssi's notify.pl knows dbus address
if [[ -n $DBUS_SESSION_BUS_ADDRESS ]];then
    echo "$DBUS_SESSION_BUS_ADDRESS" > ~/.dbus_address
fi

#if interactive, source .bashrc
[[ -n $PS1 && -f ~/.bashrc ]] && source ~/.bashrc

# vim: et:ts=4:sw=4