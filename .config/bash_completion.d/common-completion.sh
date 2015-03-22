#!/usr/bin/env bash

# Bash Completion functions
#
# From: man bash | less +/^\ *Programmable\ Completion
#     If a shell function is being invoked, the COMP_WORDS and COMP_CWORD
#     variables are also set.  When the function or command is invoked, the
#     first argument ($1) is the name of the command whose arguments are being
#     completed, the second argument  ($2)  is  the  word being completed, and
#     the third argument ($3) is the word preceding the word being completed on
#     the current command line.  No filtering of the generated completions
#     against the word being completed is performed; the function or command
#     has complete freedom in generating the matches.
#
# More on `complete` builtin:
#   man bash | less +/^\ *SHELL BUILTIN COMMANDS
#   help complete # kind of empty


_git_commit () {
  local cur prev ng_set

  # do nothing if we're not in a repo
  git rev-parse 2>/dev/null || return 0

  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  # complete uncommitted files
  if [[ ${COMP_WORDS[1]} = "commit" ]]; then
    COMPREPLY=( $(compgen -W "\
                $( while read file; do
                     echo ${file:2}
                   done < <(git status -s) )" -- $cur ) )
  fi
}

# TODO(zacsh) Figure out hwo to get this working
# complete -E -o filenames -F _git_commit
