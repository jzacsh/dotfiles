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
    -exec bash -c 'echo -n > {}' \;

  # fill cache in need
  [ "$(stat --printf='%s' "$cache")" = 0 ] && go list ... > "$cache"

  # do the obvious
  COMPREPLY=( $(compgen -W "$(< "$cache")" -- "${COMP_WORDS[$COMP_CWORD]}") )
}

__godoc_completion_subcmd() {
  # From `go help` on 2016-06-22 16:39:01-04:00
  local subcmds=(
    build
    clean
    doc
    env
    fix
    fmt
    generate
    get
    install
    list
    run
    test
    tool
    version
    vet
    help
  )
  if [ $COMP_CWORD -eq 1 ];then
    COMPREPLY=( $(compgen -W "${subcmds[*]}" -- "${COMP_WORDS[$COMP_CWORD]}") )
    return
  fi

  local prev; prev=${COMP_WORDS[COMP_CWORD-1]}
  [ -n "${prev/ */}" ] || return

  local isKnown=0
  for known in "${subcmds[@]}"; do
    [ "$prev" = "$known" ] && { isKnown=1; break; }
  done

  if [ $isKnown -eq 1 ];then __godoc_completion; fi
}

complete -o bashdefault -o nospace -F __godoc_completion        -- godoc
complete -o bashdefault -o nospace -F __godoc_completion_subcmd -- go
