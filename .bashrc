# If not running interactively, don't do anything
[[ ${-} = ${-/i/} ]] && return

# External config
[[ -r ~/.dircolors && -x /bin/dircolors ]] && eval $(dircolors -b ~/.dircolors)
[[ -r ~/.hgbashrc ]] && source ~/.hgbashrc

[ ! -e ~/.config/bash_completion.d/npm-run-completion.sh ] &&
  npm completion > ~/.config/bash_completion.d/npm-run-completion.sh

for completion in ~/.config/bash_completion.d/*.sh; do
  source "$completion"
done

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

if who | grep --invert-match $(whoami) > /dev/null;  then
    printf "Currently on %s, other than you:\n" "$(uname -snr)"
    who --heading
fi


PS1='[\u@\h] ${?} $(vcprompt) \w\n\$ ' # simple version of below

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
  PS1="${TITLEBAR}${col_blu}${col_end}${col_usr}\u@${col_end}${col_blu}\h${col_end}${RET_VALUE}"' \[\033[0;32m\]$(vcprompt)\[\033[0m\]'" ${col_ylw}\w${col_end}\n${col_blu}${col_end}\t${col_ylw} \$${col_end} "
  PS4='+$BASH_SOURCE:$LINENO:$FUNCNAME: '
}
PROMPT_COMMAND='RET=$?' # see: man bash | less +/PROMPT_COMMAND
bash_prompt
unset bash_prompt


#
# $UID > 0 BELOW THIS LINE
#   everything above *should* be plain old shell options, nothing executable
#
[[ "$UID" -eq "0" ]] && return


source ~/bin/share/zacsh_exports
[[ -r ~/.bash_aliases ]] && source ~/.bash_aliases

# for irssi's notify.pl
[[ -n $DBUS_SESSION_BUS_ADDRESS ]] &&
  echo "$DBUS_SESSION_BUS_ADDRESS" > ~/.dbus_address

source $HOME/.host/pick  # Dynamic config

if [ -z "$SSH_AUTH_SOCK" ]; then
  eval $(ssh-agent -s)
  ssh-add ~/.ssh/add/*.add #load ssh keys
fi

#must be after PATH:, apparently this will break if non-interactive shell `return`'s above.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# in my nested tmux shells, my inherited `env` is old
dbusSessionBusAddress="$(< ~/.dbus_address 2>/dev/null)"
if [ -n "$dbusSessionBusAddress" ];then
  export DBUS_SESSION_BUS_ADDRESS="$dbusSessionBusAddress"
else
  unset dbusSessionBusAddress
fi

#laughs:
#@TODO: make this fail on redirects (eg.: open wifi login pages)
#  curl -s --connect-timeout 1 --max-time 1 \
#      http://whatthecommit.com/index.txt \
#      2>/dev/null & &>/dev/null
#  sleep 1
#  kill $! &>/dev/null

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

true # don't assume last return status
