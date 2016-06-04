#!/usr/bin/env bash
#
# Autocompletion for github.com/jzacsh/punch

__punchClientCompletion() {
  [ "${COMP_WORDS[COMP_CWORD-1]}" = -c ] || return 0 # only autocomplete clients

  local clients; clients="$(punch -C | sed -e 's|\s.*$||')"
  COMPREPLY=( $(compgen -W "${clients[@]}" -- "${COMP_WORDS[$COMP_CWORD]}") )
}

complete -F __punchClientCompletion punch
