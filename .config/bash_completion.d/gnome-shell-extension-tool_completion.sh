#!/usr/bin/env bash
#
# Autocompletion for gnome-shell-extension-tool
#

# Per: man bash | less +/'^\s*Programmable\ Completion'
#   When the function or command is invoked, the first argument ($1) is the name
#   of the command whose arguments are being completed, the second argument ($2)
#   is the word being completed, and the third argument ($3) is the word
#   preceding the word  being  completed  on the current command line.
_gset_completion() {
  # we only auto-complete for "enabled" and "disabled" flags
  { [ "$3" = -e ] || [ "$3" = -d ]; } || return 0

  # extensions already enabled in gnome-shell
  local nabled
  nabled="$(
    dconf read /org/gnome/shell/enabled-extensions |
      \sed -e "s|^\['||" -e "s|'\]$||" -e "s|', '|\n|g"
  )"

  # extensions available on this machine
  local avail; avail="$(
    for dir in {~/.local,/usr/}/share/gnome-shell/extensions/*; do
      basename "$dir"
    done
  )"

  local results
  if [ "$3" = -e ];then
    results="$(
      \diff \
        <(printf '%s\n' "${avail[@]}" | sort) \
        <(printf '%s\n' "${nabled[@]}" | sort) \
       | \grep -- '^<' | \sed -e 's|^< ||'
    )"
  elif [ "$3" = -d ];then
    results="$nabled"
  fi

  COMPREPLY=( $(compgen -W "$results" -- "${COMP_WORDS[$COMP_CWORD]}") )
}

complete -F _gset_completion gnome-shell-extension-tool
