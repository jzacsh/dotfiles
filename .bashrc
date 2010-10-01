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
    PS1="${col_ylw}$(uname -n)${col_end}"
    export LESSOPEN="| lesspipe.sh %s"
#    export LESSOPEN="| /usr/bin/source-highlight %s"
#    export LESSOPEN="| /usr/bin/lesspipe.sh %s| /usr/bin/source-highlight %s"
elif [[ $(uname -n) == "penguinix" || $(uname -n) == "cnyitjza" ]];then
    PS1="${col_red}$(uname -n)${col_end}"
    export LESSOPEN="|lesspipe.sh %s"
    export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
  else
    PS1="${col_ylw}$(uname -n)${col_end}"
fi
PS1="${PS1}${col_blu}::${col_end}"
PS1="${PS1}${col_grn}$(pwd | tail -c 23)${col_end}"
PS1="${PS1}${col_blu}\$${col_end} "
export PS1
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
