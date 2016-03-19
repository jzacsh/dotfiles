#!/usr/bin/env bash
#
# Autocompletion for gnome-shell-extension-tool
#

__get_avilable_extensions() {
  for dir in {~/.local,/usr/}/share/gnome-shell/extensions/*; do
    basename "$dir"
  done
}

# Per: man bash | less +/'^\s*Programmable\ Completion'
#   When the function or command is invoked, the first argument ($1) is the name
#   of the command whose arguments are being completed, the second argument ($2)
#   is the word being completed, and the third argument ($3) is the word
#   preceding the word  being  completed  on the current command line.
_gset_completion() {
  { [ "$3" = -e ] || [ "$3" = -d ]; } || return 0

  local exts; exts="$(__get_avilable_extensions)"
  COMPREPLY=( $(compgen -W "$exts" -- "${COMP_WORDS[$COMP_CWORD]}") )
}

complete -F _gset_completion gnome-shell-extension-tool
