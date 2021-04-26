#!/usr/bin/env bash

#if interactive, source .bashrc
[[ -n $PS1 && -f ~/.bashrc ]] && source ~/.bashrc

# TODO: consider moving much of ~/.bashrc contents into _this_ file  so it's not
# executing at every shell (eg: ~/.host/pick content?)

# vim: et:ts=4:sw=4
