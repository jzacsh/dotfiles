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

#path:
export PATH=$PATH:$HOME/bin:/opt/java/jre/bin/
#export PS1='$(uname -n)::$(pwd | tail -c 23)$ '

if [[ $(uname -n) == "jznix" ]];then
    export PS1='\[\e[1;33m\]$(uname -n)\[\e[m\]\[\e[1;34m\]::\[\e[m\]\[\e[1;32m\]$(pwd | tail -c 23)\[\e[m\]\[\e[1;34m\]$\[\e[m\] '
    export LESSOPEN="| lesspipe.sh %s"
#    export LESSOPEN="| /usr/bin/source-highlight %s"
#    export LESSOPEN="| /usr/bin/lesspipe.sh %s| /usr/bin/source-highlight %s"
elif [[ $(uname -n) == "penguinix" || $(uname -n) == "cnyitjza" ]];then
    export PS1='\[\e[1;31m\]$(uname -n)\[\e[m\]\[\e[1;34m\]::\[\e[m\]\[\e[1;32m\]$(pwd | tail -c 23)\[\e[m\]\[\e[1;34m\]$\[\e[m\] '
    export LESSOPEN="|lesspipe.sh %s"
    export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
fi

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
