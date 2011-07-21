#!/usr/bin/env bash
# aliases #####################
alias ls='ls --color'
alias l='ls -laFH'
alias la='ls -aFH'
alias ca='clear; ls -laFH'
alias cl='clear; ls -lFH'
alias diff='colordiff'
alias mi="curl -s http://checkip.dyndns.org | sed -e 's/^.*Address:\ //' -e 's/<\/body.*//'"
alias tas='tmux attach-session'
alias td='tmux detach-client'
alias udevinfo='udevadm info -q all -n'
alias mutt='pgrep mutt && mutt -R || mutt'
alias ipt='sudo iptraf'
alias goh='ssh home.jzacsh.com'
alias pdf='xpdf'
alias da='django-admin.py'
alias hh='curl --head'
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
alias hc='hg commit -m'
alias hgk='hgview 2> /dev/null & disown'
alias node='NODE_NO_READLINE=1 rlwrap node'
alias nc='ncmpcpp'

# x env #######################
alias br='$BROWSER'
alias ch='chromium-browser'
alias kflash='echo -n "killing flash..." && sudo killall npviewer.bin'

## common spelling mistakes ###
alias les='less'
alias duff='echo "no beer here, try \`diff\`."'
alias :w='echo "yeahh... this is not vim." >&2'
alias :q=':w'
alias :e=':w'
alias :x=':w'
if [[ $(type -p libreoffice) ]];then
    alias office='libreoffice'
elif [[ $(type -p ooffice) ]];then
    # i never manage to type that extra 'o'
    alias office='ooffice'
elif [[ $(type -p abiword) ]];then
    alias office='abiword'
else
    office() {
        echo 'Sorry, no office suite installed!' >&2
        return 1
    }
fi

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
hgdiff() ( hg cat $1 | vim - -c  ":vert diffsplit $1" -c "map q :qa!<CR>"; )
speak() { echo ${@} | espeak 2>/dev/null; }
ident() ( identify -verbose $1 | grep modify; )
g() ( IFS=+; $BROWSER "http://www.google.com/search?q=${*}"; )
wat() ( curl -s ${@} | $PAGER; )
rfc() { curl -s "http://tools.ietf.org/rfc/rfc${1}.txt" | $PAGER +/-.[0-9]*.-.*RFC\ \#${1}; }

#tmux/ssh/console considerations
alias xf='DISPLAY=localhost:10.0 '
alias xl='DISPLAY=:0.0 '

shot() {
  if ! type -p import >& /dev/null; then
    echo "Error: \`import' not found on your system." >&2
    return 1
  fi

  local ftype file
  ftype=${SHOT_ENC:-png}
  file="screenshot_$(date +%s).${ftype}"
  if (( $# ));then
    if [[ -d $1 ]];then
      # drop the default file-name in their chosen dir
      file="${1}/${file}"
    else
      # we might need to tack on an extension
      local len="${#1}"
      local dot=$((len - 4))
      if [[ "${1:$dot:1}" = . ]];then
        local ext
        ext=$((len - 3))
        ftype=${1:$ext}
        file="${1}"
      else
        #no extension was given
        file="${1}.${ftype}"
      fi
    fi
  fi

  import -encoding "$ftype" "$file"
}

e() {
    #@TODO: do this for `br` alias.
    if [[ -n $DISPLAY ]];then
        case $DESKTOP_SESSION in
            'DWM')
                $BROWSER
                ;;
            'gnome')
                nautilus --browser
                ;;
            'xfce')
                thunar
                ;;
            *)
        esac
    else
        echo 'No DESKTOP_SESSION found, are you even running X?' >&2
    fi
}

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
  if [[ $1 = "-n" ]]; then
    local opt=''
  else
    local opt='-delete -print'
  fi

  find $PROJECT_BASE -name '*.orig' ${opt}
}

mp() {
  'error: this should take care of shitty microsoft paths, but it is broken.' >&2
#  echo "smb://$(echo ${*} | sed -e 's/\\/\//g' | sed -e 's/\ /\\\ /g')"
  echo smb://$(echo "${*}" | sed -e 's/\\/\//g' | sed -e 's/\ /\\\ /g')
}

let_my_swaps_go() {
  #tell linux to clear out swap; useful for long running desktop
  sudo swapoff -a
  sudo swapon -a
}

