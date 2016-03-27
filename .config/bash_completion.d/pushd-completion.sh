#!/usr/bin/env bash
#
# Taken from https://bugzilla.novell.com/show_bug.cgi?id=818365

if shopt -q cdable_vars; then
    complete -v -F _cd -o nospace cd pushd
else
    complete -F _cd -o nospace cd pushd
fi
