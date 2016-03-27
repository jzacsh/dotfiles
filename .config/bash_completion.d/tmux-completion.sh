#!/usr/bin/env bash
# bash completion for tmux
#   Forked from https://gist.github.com/cybic/6375457 at 57f0cb50a14dff6

_tmux_completion() {
  local comp
  local cur="${COMP_WORDS[COMP_CWORD]}"

  local prev="${COMP_WORDS[COMP_CWORD-1]}"
  if [ "$prev" = tmux ];then
    comp="$({
      tmux list-commands | cut -f 1 -d ' ' &&
        tmux list-commands | cut -f 2 -d ' ' |
          grep '^(.*)$' |
          sed -e 's|^(\(.*\))$|\1|'
     } | sort)"
  else
    case "$prev" in
      attach*)
        comp="-t"
        ;;
      -t)
        comp="$(tmux ls -F'#{session_name}')"
        ;;
    esac
  fi

  COMPREPLY=( $(compgen -W "$comp" -- "$cur") )
}

complete -F _tmux_completion tmux
