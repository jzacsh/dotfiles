#!/usr/bin/env bash
#
# Autocompletion for gnome-shell-extension-tool

# Per: man bash | less +/'^\s*Programmable\ Completion'
#   When the function or command is invoked, the first argument ($1) is the name
#   of the command whose arguments are being completed, the second argument ($2)
#   is the word being completed, and the third argument ($3) is the word
#   preceding the word  being  completed  on the current command line.
__godoc_completion() {
  local cacheTtl=60 # minutes

  # ensure we can even cache
  local cache; cache="${TMPDIR:-/tmp}/godoc-${USER}-completion_cache"
  { [ -e "$cache" ] || echo -n > "$cache" >/dev/null 2>&1; }
  { [ $? -eq 0 ] && [ -f "$cache" ] && [ -w "$cache" ]; } || {
    printf '\nError: cannot autocomplete godoc; problem w/cache file. Fix $TMPDIR or /tmp/\n' >&2
    return 1
  }

  # clear old cache
  find "$(dirname "$cache")" \
    -mindepth 1 -maxdepth 1 \
    -type f -name "$(basename "$cache")" \
    -mmin +$cacheTtl \
    -exec echo -n > {} \;

  # fill cache in need
  [ "$(stat --printf='%s' "$cache")" = 0 ] && go list ... > "$cache"

  # do the obvious
  COMPREPLY=( $(compgen -W "$(< "$cache")" -- "${COMP_WORDS[$COMP_CWORD]}") )
}

complete -F __godoc_completion -- godoc
