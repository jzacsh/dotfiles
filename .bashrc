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

#export PS1='$(uname -n)::$(pwd | tail -c 23)$ '
#
#colors:
col_red='\[\e[1;31m\]'
col_grn='\[\e[1;32m\]'
col_ylw='\[\e[1;33m\]'
col_blu='\[\e[1;34m\]'
col_end='\[\e[m\]'

export CLASSPATH=.:$CLASSPATH:$HOME/docs/edu/he/bcc/2010-2011/fall2010/comp171/comp/jzacsh/:$HOME/docs/edu/comp171/comp/jzacsh
export EDITOR=vim
export PATH=$PATH:$HOME/bin:/opt/java/jre/bin/:/srv/http/global/bin/dev/
if [[ $(uname -n) == "jznix" ]];then
    export LESSOPEN="| lesspipe.sh %s"
#    export LESSOPEN="| /usr/bin/source-highlight %s"
#    export LESSOPEN="| /usr/bin/lesspipe.sh %s| /usr/bin/source-highlight %s"
elif [[ $(uname -n) == "penguinix" || $(uname -n) == "cnyitjza" ]];then
    export LESSOPEN="|lesspipe.sh %s"
    export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
fi
RET_VALUE='$(if [[ $RET -ne 0 ]];then echo -n ":\[\033[1;31m\]$RET\[\033[0m\]";fi)'
PS1="$TITLEBAR ${EMK}┌┤${UC}\u${EMK}@${UC}\h${RET_VALUE}"'$(__git_ps1 " \[\033[0;32m\]%s\[\033[0m\]")'" ${EMB}\w${NONE}${EMK}${UC}\n ${EMK}└╼${NONE} "
PS4='+$BASH_SOURCE:$LINENO:$FUNCNAME: '
export LESS=' -XFRr '

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

echo "AhMG!! SEGMENTATION FAULT"
