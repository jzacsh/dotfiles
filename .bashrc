# If not running interactively, don't do anything
[[ ${-} = ${-/i/} ]] && return

source ~/.git-completion.bash

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# External config
[[ -r ~/.bash_aliases ]] && . ~/.bash_aliases
[[ -r ~/.dircolors && -x /bin/dircolors ]] && eval $(dircolors -b ~/.dircolors)
[[ -r ~/.hgbashrc ]] && . ~/.hgbashrc

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
# set -o vi

# turn off control character echoing
stty -ctlecho

# history options
export HISTIGNORE="&:ls:[bf]g:exit:hg in:hg out:reset:clear:ca:cl:l:cd*"
export HISTFILESIZE=2000
export HISTCONTROL="ignoreboth"
export HISTSIZE=500

#`who` else loged in:
if [[ $(who | grep -v $(whoami)) ]]; then
    printf "Currently on %s, other than you:" $(uname -snr)
    who -H | grep -v $(whoami)
fi

#simple version of bash prompt:
PS1='[\u@\h] ${?} $(vcprompt) \w\n\$ '

#vcs and color-aware version of bash prompt:
bash_prompt() {
  case $TERM in
    xterm*|rxvt*)
      local TITLEBAR='\[\033]0;\u:${NEW_PWD}\007\]' ;;
    *)
      local TITLEBAR="" ;;
  esac

  #export PS1='$(uname -n)::$(pwd | tail -c 23)$ '
  #
  #colors:
  local col_end='\[\033[0m\]'

  local col_blk='\[\e[0;30m\]'
  local col_red='\[\e[1;31m\]'
  local col_grn='\[\e[1;32m\]'
  local col_ylw='\[\e[1;33m\]'
  local col_blu='\[\e[1;34m\]'
  local col_wht='\[\e[0;37m\]'

  local col_usr=$col_grn
  [[ $UID -eq "0" ]] && col_usr=$col_red #root's color

  RET_VALUE='$(if [[ $RET -ne 0 ]];then echo -n ":\[\033[1;31m\]$RET\[\033[0m\]";fi)'
  PS1="$TITLEBAR${col_blu}┌┤${col_end}${col_usr}\u@${col_end}${col_blu}\h${col_end}${RET_VALUE}"' \[\033[0;32m\]$(vcprompt)\[\033[0m\]'" ${col_ylw}\w${col_end}\n${col_blu}└╼${col_end} "
  PS4='+$BASH_SOURCE:$LINENO:$FUNCNAME: '
}

PROMPT_COMMAND='RET=$?'
bash_prompt
unset bash_prompt

#dynamic config:
source $HOME/.host/pick

#load ssh keys
eval $(keychain --nogui --eval --timeout ${KEY_TIMEOUT:-240} ~/.ssh/add/*.add)
# NOTE: to load keys on this machine setup in ~/.ssh/add/:
# lrwxrwxrwx   jzlut.add -> ../jzlut
# lrwxrwxrwx   jzlut.add.pub -> ../jzlut.pub

#must be after PATH:, apparently this will break if non-interactive shell `return`'s above.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

#laughs:
#@TODO: make this fail on redirects (eg.: open wifi login pages)
#  curl -s --connect-timeout 1 --max-time 1 \
#      http://whatthecommit.com/index.txt \
#      2>/dev/null & &>/dev/null
#  sleep 1
#  kill $! &>/dev/null
