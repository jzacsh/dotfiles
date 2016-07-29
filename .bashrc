# If not running interactively, don't do anything
[[ ${-} = ${-/i/} ]] && return

{ [ -r ~/.dircolors ] && type dircolors >/dev/null 2>&1; } &&
    eval $(dircolors --bourne-shell ~/.dircolors)

# shell opts
shopt -s cdspell
shopt -s extglob
shopt -s histverify
shopt -s histappend
shopt -s no_empty_cmd_completion
shopt -s dirspell

# notify of completed background jobs immediately
set -o notify
set +o histexpand
set -o vi

# turn off control character echoing
stty -ctlecho

# history options
export HISTIGNORE="&:ls:[bf]g:exit:hg in:hg out:reset:clear:ca:cl:l:cd*"
export HISTFILESIZE=2000
export HISTCONTROL='ignoreboth'
export HISTSIZE=500

PS1='sh#$SHLVL [\u@\h] ${?} \w\n\$ ' # vanilla version of my prompt, with no executables


############################################################################
# $UID > 0 BELOW THIS LINE
#   everything above *should* be plain old shell options, nothing executable
[ "$UID" -eq "0" ] && return
############################################################################


PS1='sh#$SHLVL [\u@\h] ${?} $(vcprompt) \w\n\$ ' # simple version of below
# vcs and color-aware version of bash prompt:
bash_prompt() {
  case $TERM in
    xterm*|rxvt*)
      local TITLEBAR='\[\033]0;\u:${NEW_PWD}\007\]' ;;
    *)
      local TITLEBAR="" ;;
  esac

  local col_end='\[\033[0m\]'
  local col_blk='\[\e[0;30m\]'
  local col_red='\[\e[1;31m\]'
  local col_grn='\[\e[1;32m\]'
  local col_ylw='\[\e[1;33m\]'
  local col_blu='\[\e[1;34m\]'
  local col_wht='\[\e[0;37m\]'

  local col_usr=$col_grn
  if [[ $UID -eq "0" ]];then
    col_usr=$col_red #root's color
    alias vcprompt='echo -n' # don't execute `vcprompt`
  fi

  RET_VALUE='$(if [[ $RET -ne 0 ]];then echo -n ":\[\033[1;31m\]$RET\[\033[0m\]";fi)'
  PS1="${TITLEBAR}${col_blu}${col_end}${col_usr}\u@${col_end}${col_blu}\h${col_end}${RET_VALUE}"' \[\033[0;32m\]$(vcprompt)\[\033[0m\]'" ${col_ylw}\w${col_end}\n\t  ${col_grn}${SHLVL}${col_end}:${col_ylw}\$${col_end} "
  PS4='+$BASH_SOURCE:$LINENO:$FUNCNAME: '
}
PROMPT_COMMAND='RET=$?' # see: man bash | less +/PROMPT_COMMAND
bash_prompt
unset bash_prompt


source ~/bin/share/zacsh_exports
type systemctl >/dev/null 2>&1 &&
  systemctl --user import-environment PATH
[ -r ~/.bash_aliases ] && source ~/.bash_aliases
source $HOME/.host/pick  # Dynamic config
if [ -z "${SSH_AUTH_SOCK/ */}" ]; then
  eval $(ssh-agent -s)
  ssh-add ~/.ssh/add/*.add #load ssh keys
fi

# in my nested tmux shells, my inherited `env` is old
dbusSessionBusAddress="$(< ~/.dbus_address 2>/dev/null)"
if [ -n "${dbusSessionBusAddress/ */}" ];then
  export DBUS_SESSION_BUS_ADDRESS="$dbusSessionBusAddress"
else
  unset dbusSessionBusAddress
fi

# for irssi's notify.pl
[ -n ${DBUS_SESSION_BUS_ADDRESS/ */} ] &&
  echo "$DBUS_SESSION_BUS_ADDRESS" > ~/.dbus_address

############################################################################
# External Configuration. Provided by libraries, etc.; not written by me, or
# widely standard.
############################################################################

[ -r /etc/bash_completion ] && source /etc/bash_completion
for completion in ~/.config/bash_completion.d/*.sh; do
  source "$completion"
done

#must be after PATH:, apparently this will break if non-interactive shell `return`'s above.
[ -s "$HOME/.rvm/scripts/rvm" ] && source "$HOME/.rvm/scripts/rvm"

[ -r ~/.hgbashrc ] && source ~/.hgbashrc
[ ! -e ~/.config/bash_completion.d/npm-run-completion.sh ] &&
  npm completion > ~/.config/bash_completion.d/npm-run-completion.sh

# autocompletion for man pages
source /usr/share/bash-completion/bash_completion
source /usr/share/bash-completion/completions/man
complete -F _man -- mann

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Assumes you have ocaml setup, ie:
#   1) once: installed ocaml (and its pkg mgmt system, "opam", etc, etc.)
#   2) once: run `opam init`
#   3) optionally, once: installed vim ocaml things && `opam install ocp-indent`
[ -f ~/.opam/opam-init/init.sh ] && source ~/.opam/opam-init/init.sh


######################################################
# Below this line is strictly for messages to myself #
######################################################

# Highlight currently authenticated keys
ssh-add -l | grep --extended-regexp '^|\.ssh\/.*\ '
#NOTE: this should be first, since it always prints

# Users
if who | grep --invert-match "$(whoami)" > /dev/null; then
  printf '\nCurrently on %s, other than you:\n' "$(uname -snr)"
  who --heading | grep --invert-match "$(whoami)"
fi

#Laughs:
# curl --silent --location --connect-timeout 0.06 \
#     http://whatthecommit.com/index.txt 2>/dev/null

#Tmux
scowerForTmuxSessions() (
  [ -n "${TMUX/ */}" ] && return

  local havePrinted=0
  local col_end='\033[0m'; local col_grn='\e[0;32m'
  local commonTmSocks=(default main "${USER}main")
  for sock in "${commonTmSocks[@]}"; do
    local tmSessions="$(tmux -L "$sock" list-sessions 2>/dev/null)"
    [ -z "${tmSessions/ */}" ] && continue

    (( havePrinted )) || { havePrinted=1; echo; } # initial padding
    printf "tmux -L ${col_grn}%s${col_end} sessions:\n" "$sock"
    printf '%s\n' "$tmSessions" |
        GREP_COLORS='mt=01;33' \grep --color=always '^\w*:'
  done
)
scowerForTmuxSessions; unset scowerForTmuxSessions

# Print local mail waiting for me
scowerForMail() (
  local headers; headers="$(mail -H 2>&1)"
  if [ $? -eq 0 ];then
    local col_end='\033[0m'
    local col_red='\e[1;31m'

    echo -e '\n'$col_red'UNREAD'$col_end' messages; `mail` to read them:'
    printf '%s\n' "$headers"
  fi
  unset mailHeaders
)
scowerForMail; unset scowerForMail

true # don't assume last return status
