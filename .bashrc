# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source ~/.git-completion.bash

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# External config
[[ -r ~/.bash_aliases ]] && . ~/.bash_aliases
[[ -r ~/.dircolors && -x /bin/dircolors ]] && eval $(dircolors -b ~/.dircolors)

export CLASSPATH=.:$CLASSPATH:$HOME/docs/edu/he/bcc/2010-2011/fall2010/comp171/comp/jzacsh/:$HOME/docs/edu/comp171/comp/jzacsh
export EDITOR=vim
PATH=.:$HOME/bin:$HOME/bin/share:$HOME/bin/local:$HOME/bin/dist:$PATH
PATH=$PATH:/opt/java/jre/bin/:/srv/http/global/bin/dev/
export PATH
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -XFR '

# shell opts
shopt -s cdspell
shopt -s extglob
shopt -s histverify
shopt -s histappend
shopt -s no_empty_cmd_completion
shopt -s dirspell

# notify of completed background jobs immediately
set -o notify

# turn off control character echoing
stty -ctlecho

# history options
export HISTIGNORE="&:ls:[bf]g:exit:reset:clear:cd*"
export HISTFILESIZE=2000
export HISTCONTROL="ignoreboth"
export HISTSIZE=500

#`who` else loged in:
if [[ $(who | grep -v jzacsh) ]]; then
	echo "Currently on `uname -snr`, other than you:"
	who -H | grep -v jzacsh
	echo #spacer
fi

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
  PS1="$TITLEBAR ${col_blk}┌┤${col_end}${col_usr}\u@${col_end}${col_blu}\h${col_end}${RET_VALUE}"'$(__git_ps1 " \[\033[0;32m\]%s\[\033[0m\]")'" ${col_ylw}\w${col_end}\n ${col_blk}└╼${col_end} "
  PS4='+$BASH_SOURCE:$LINENO:$FUNCNAME: '
}

PROMPT_COMMAND='RET=$?'
bash_prompt
unset bash_prompt

# resize -s 400 400
echo 'AhMG!! SEGMENTATION FAULT'


