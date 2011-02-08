#!/usr/bin/env bash
# aliases #####################
alias ls='ls --group-directories-first --color'
alias l='ls -laFH'
alias la='clear; ls -aFH'
alias ca='clear; ls -laFH'
alias cl='clear; ls -lFH'
alias diff='colordiff'
alias mi="wget -qO- http://checkip.dyndns.org | sed -e 's/^.*Address:\ //' -e 's/<\/body.*//'"
alias tas="tmux attach-session"
alias td="tmux detach-client"
alias udevinfo='udevadm info -q all -n'
alias mutt='pgrep mutt && mutt -R || mutt'
alias ipt="sudo iptraf"
alias goh="ssh home.jzacsh.com"

# x env #######################
alias br='$BROWSER'
alias ch='chromium-browser'
alias kflash='echo "killing flash..." && sudo killall npviewer.bin'
alias xt='xterm -bg black -fg white -maximized'
alias rx='rxvt -bg black -fg white -geometry 300x100 -face10'
alias urx='rxvt-unicode -bg rgba:1111/1111/1111/bbbb -fg white -fn "xft:Droid Sans Mono:pixelsize=10"'

## common spelling mistakes ###
alias les='less'
alias office='ooffice'

## dropbox can suck: ##########
dropx() {
  local db="dropbox"
  for act in {op,art,atus}; do $db st${act}; done
  for i in {1..5}; do sleep 1 && $db status; done
  for i in {1..15}; do sleep 2 && $db status; done
}

###############################
# functions ###################
#one liners
lu() ( dict ${@} | $PAGER; )
tarl() ( tar -tf ${*}  | $PAGER; )
hc() ( hg commit -m ${@}; )
hgdiff() ( hg cat $1 | vim - -c  ":vert diffsplit $1" -c "map q :qa!<CR>"; )
speak() { echo ${@} | espeak 2>/dev/null; }
ident() ( identify -verbose $1 | grep modify; )
g() ( IFS=+; $BROWSER "http://www.google.com/search?q=${*}"; )
rfc() { wget -cqO- "http://tools.ietf.org/rfc/rfc${1}.txt" | $PAGER +/-.[0-9]*.-.*RFC\ \#${1}; }
wat() ( wget -cqO- ${@} | $PAGER; )
hh() { wget -qS -O /dev/null ${@}; } #Http Headers

addkeys () {
    local timeout nums

    if [[ $1 = '-h' || $1 = '--help' ]];then
        echo "
        usage: $FUNCNAME -t [timeout] [keys ...]
        add sshkeys to keychain(1)
        timeout is minutes until keys are cleared. defaults to 240
        keys additional ssh keys you'd like added. defaults to ~/.ssh/add/*.add
        " >&2
        return 1
    elif [[ ! $(type -p keychain) ]]; then
        echo "error: keychain not found" >&2
        return 2
    fi

    if [[ $1 = '-t' ]];then
        nums='^[0-9]+([.][0-9]+)?$'
        if [[ -n $2 && $2 =~ $nums ]];then
            timeout=$2
            shift 2
        else
            echo "error: numeric timeout value not passed." >&2
            return 2
        fi
    fi

    #actually do something:
    eval $(keychain --nogui --eval --timeout ${timeout:-240} ~/.ssh/add/*.add ${@})
}

hgk() {
	hgview 2> /dev/null &
	disown
}

xfw() {
  DISPLAY=localhost:10.0 ${@}
}

xdb() {
  local uri_append='?XDEBUG_SESSION_STOP'
  [[ -z $1 ]] && uri_append='?XDEBUG_SESSION_START=1'
  echo -en $uri_append
}

trans() {
  local orig="$1"
  local targ="$2"
  shift;shift
  local text="$*"
  local google_api='http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q='
  local url="${google_api}${text// /+}&langpair=${orig}|${targ}"
  curl ${url} 2>/dev/null #| sed 's/.*"translatedText":"\([^"]*\)".*}/\1\n/'
}

tmp() {
  local tmpfile=$(mktemp)

  if [[ $1 == 'c' ]]; then
    $EDITOR $tmpfile && $BROWSER $tmpfile
  else
    $EDITOR $tmpfile && dpaste < $tmpfile
  fi

  #cleanup
  sleep 5 && rm $tmpfile
}

gencscope() {
  if [[ $(uname -n) == "jznix" ]];then
    local DIRS=(/srv/http/subs/notes/www/{sites/all/{modules/contrib,themes},includes,modules})
  else
    local DIRS=(~/code/web5-jzacsh/{sites/all/{modules/contrib,themes},includes,modules})
  fi
  cscope -b -i <(find "${DIRS[@]}" \( -name '*.inc' -or -name '*.php' -or -name '*.module' \))
}

urlhg() {
  echo -en 'Error: not yet implemented.\n'
  echo -en '       this function will return a line-specific url\n'
  echo -en '       to codelibrary given a local file.\n'
  echo -en "       eg.: 'http://codelibrary.zagat.com/hg/integration/web5-jzacsh/file/5d56162a25f8/index.php#l4'\n"
  return 1
}

urlocal() {
  echo -en 'Error: not yet implemented.\n'
  echo -en '       this function will return a local-url\n'
  echo -en '       to this host given a local file.\n'
  echo -en "       eg.: 'http://cnyitjza.zagat.com/sites/all/themes/zagat/css/global.css'\n"
  return 1
}

origrm() {
  [[ -z $PROJECT_BASE ]] && return 1
  if [[ $1 == "-n" ]]; then
    local opt=''
  else
    local opt='-delete -print'
  fi

  find $PROJECT_BASE -name '*.orig' ${opt}
}

mp() {
#  echo "smb://$(echo ${*} | sed -e 's/\\/\//g' | sed -e 's/\ /\\\ /g')"
  echo smb://$(echo "${*}" | sed -e 's/\\/\//g' | sed -e 's/\ /\\\ /g')
}
