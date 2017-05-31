#!/usr/bin/env bash

__punchClientCompletion() {
  local subcmds
  declare -r subcmds='punch bill query delete amend help'

  if (( COMP_CWORD == 1 ));then
    COMPREPLY=( $(compgen -W "-h $subcmds" -- "${COMP_WORDS[$COMP_CWORD]}") )
    return
  fi

  local subCmd; subCmd="${COMP_WORDS[1]}"
  local prevArg; prevArg="${COMP_WORDS[COMP_CWORD-1]}"

  [[ "$subcmds" = "${subcmds/$subCmd/}" ]] &&
      return # bail; not autocompleting args to any valid subcommand

  case "$subCmd" in
    p|punch|bill|d|delete|h|help) ;;
    *) return ;; # currently only implement autocompletion of CLIENT args
  esac

  local nextArgs; nextArgs="$(punch query list)" # clients

  case "$subCmd" in
    h|help)
      COMPREPLY=( $(compgen -W "${subcmds/help/}" -- "${COMP_WORDS[$COMP_CWORD]}") )
      return
      ;;
    p|punch)
      local hasNoteArg=0
      for (( i=1; i < COMP_CWORD; i+=1 ));do
        if [[ "${COMP_WORDS[$i]}" = '-n' ]];then
          hasNoteArg=1
        fi
      done

      if ! (( hasNoteArg ));then nextArgs+=' -n '; fi

      if (( COMP_CWORD == 3 )) && ! (( hasNoteArg ));then
        COMPREPLY=( $(compgen -W ' -n ' -- "${COMP_WORDS[$COMP_CWORD]}") )
        return
      elif (( COMP_CWORD > 3 )); then
        return
        # we don't offer completion past 'punch' subcmd w/CLIENT and note already
        # provided
      fi
      ;;
    bill)
      local billFlags; billFlags='-f -t -n'
      case $COMP_CWORD in
        2) ;; # continue on w/normal CLIENT completion
        3)
          COMPREPLY=( $(compgen -W "${billFlags} -d" -- "${COMP_WORDS[$COMP_CWORD]}") )
          return
          ;;
        4|5|6|7|8)
          if [[ "$billFlags" != "${billFlags/$prevArg/}" ]];then
            return  # still waiting on argument to last flag
          fi

          for (( i=2; i < COMP_CWORD; i+=1 ));do
            ithArg="${COMP_WORDS[$i]}"
            billFlags="${billFlags/"$ithArg"/}"
          done

          [[ -n "${billFlags// }" ]] || return # nothing left to complete

          COMPREPLY=( $(compgen -W "$billFlags" -- "${COMP_WORDS[$COMP_CWORD]}") )
          return
          ;;
        *) return ;; # we've a full commandline for `bill`
      esac
      ;;
    d|delete)
      if (( COMP_CWORD == 2 ));then
        COMPREPLY=( $(compgen -W 'bill punch' -- "${COMP_WORDS[$COMP_CWORD]}") )
        return
      elif (( COMP_CWORD == 4 ));then
        COMPREPLY=( $(compgen -W ' -d ' -- "${COMP_WORDS[$COMP_CWORD]}") )
        return
      elif (( COMP_CWORD > 4 ));then
        return # we've a full commandline (might still be waiting for AT timestamp arg)
      fi
      ;;
  esac

  COMPREPLY=( $(compgen -W "${nextArgs[@]}" -- "${COMP_WORDS[$COMP_CWORD]}") )
}

complete -F __punchClientCompletion punch
