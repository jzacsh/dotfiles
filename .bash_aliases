#!/usr/bin/env bash

[[ "$BASH_VERSINFO" != 4 ]] && exit 1

# aliases #####################
alias ls='ls --color'
alias l='ls -laFH'
alias la='ls -aFH'
alias ca='clear; ls -laFH'
alias cl='clear; ls -lFH'
alias diff='colordiff'
alias mi="curl -s http://checkip.dyndns.org | sed -e 's/^.*Address:\ //' -e 's/<\/body.*//'"
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
type -p node >& /dev/null && alias node='NODE_NO_READLINE=1 rlwrap node'
alias nc='ncmpcpp'
alias o='xdg-open'
alias lint='lintch'
alias pfresh='pfresh -w'
alias eclimd='"$ECLIPSE_HOME"/eclimd'
alias vim='vim -X'
alias html='w3m -dump -T text/html'
alias pastie="$PASTIE"

alias mail='vmail' # tiny script that wraps mail in `mktemp`/$EDITOR calls

# most commonly I'd like to convert: decimal <=> hex
alias tohex="printf '0x%x\n'"
alias fromhex="printf '%0.0f\n'"

# x env #######################
alias br='$BROWSER'
alias ch='chromium-browser'
alias kflash='echo -n "killing flash..." && sudo killall npviewer.bin'
# swaps caps with right-control
alias fixcaps='setxkbmap -option ctrl:swapcaps'

## common spelling mistakes ###
alias vi='vim'
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
g() ( IFS=+; $BROWSER "http://www.google.com/search?q=${*}"; )
tarl() ( tar -tf ${*}  | $PAGER; )
hgdiff() ( hg cat $1 | vim - -c  ":vert diffsplit $1" -c "map q :qa!<CR>"; )
speak() { echo ${@} | espeak 2>/dev/null; }
ident() ( identify -verbose $1 | grep modify; )
geo() ( identify -verbose $1 | grep geometry; )
wat() ( curl -Ls ${@} | $PAGER; )
rfc() { curl -s "http://tools.ietf.org/rfc/rfc${1}.txt" | $PAGER +/-.[0-9]*.-.*RFC\ \#${1}; }
hgchanged() { hg -q in ${1} --template='{files}\n'; }
t() { tmux -L main "${@:-attach}"; } #tmux
td() { t detach; }
json () { type json >& /dev/null && command json || python -mjson.tool ; }

#`hg shelve` extension is broken for some reason.
hgunshelve () {
  local patch

  if [[ $1 = -l ]];then
    ls -la "$(hg root)/.hg/shelves/"
  else
    patch="$(hg root)/.hg/shelves/$1"

    if [[ -f $patch && -w "$patch" ]];then
      pushd "$(hg root)" #run patch cmd. from top-level
      patch -p1 < "$patch"
      if (( $? == 0 ));then
        read -p 'Patch successfull; Remove patch file? [Y/n] ' answ
        [[ "${answ/,,}" == y ]] && rm -v "$patch"
      fi
      popd
    else
      printf 'Error: not a writeable patch file: "%s".\n' "" >&2
      return 1
    fi
  fi
}

#tmux/ssh/console considerations
alias xf='DISPLAY=localhost:10.0 '
alias xl='DISPLAY=:0.0 '

#alevine's trick
avi() {
 if [[ ! -r "$1" ]] || (( $# ));then
   local num
   num=$(find ./ -type f -name "$1" | wc -l)
   (( num = 1 )) && command $EDITOR $(find ./ -type f -name "$1") || find ./ -type f -name "${*}"
 else #just open the editor
   command $EDITOR "${*}"
 fi
}

#dictionary look ups
lu() {
  local url query none google ln=0
  while read -u 3 line;do
    if (( ln ));then
      echo "$line" >&1
    else
      IFS=+; url="http://www.google.com/search?q=define:${*}"
      none="${line/No definitions found for*/}"
      if [[ -z $none ]];then
        #look for fallbacks to dict(1)

        #fallback to Google's "define:" query trick
        echo -n 'dict(1) returned no results, google? [Y/n] ' >&2
        read -u 0 google
        echo >&2 #NOTE: we use fd 2 here because 1 will be trapped here
        if [[ -z "$google" || "${google^^}" = Y ]];then
          if [[ -n $BROWSER ]];then
            command $BROWSER "$url"
          else
            echo -e "Visit: $url" >&2
          fi
        fi
        break
      else
        echo "$line" #everything's fine, using `dict`
      fi
    fi
    ln=$(( ln + 1 ))
  done 3< <(dict ${@} 2>&1) | $PAGER
}

#file explorer
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

#ssh key management
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

#allow xdebug step-through of php-cli
xdb() {
  [[ -z $1 ]] && XDEBUG_CONFIG="idekey=netbeans-xdebug" "${*}"
}

#translate
trans() {
  local orig="$1"
  local targ="$2"
  shift;shift
  local text="$*"
  local google_api='http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q='
  local url="${google_api}${text// /+}&langpair=${orig}|${targ}"
  curl ${url} 2>/dev/null #| sed 's/.*"translatedText":"\([^"]*\)".*}/\1\n/'
}

#temp file for pasting purposes
tmp() {
  local tmpfile="$(mktemp)"

  if [[ $1 = c ]]; then
    #will paste with clipboard/x11
    "$EDITOR" "$tmpfile" && "$BROWSER" "$tmpfile"
  else
    #will use proper pastie
    "$EDITOR" "$tmpfile" && "$PASTIE" < "$tmpfile"
  fi

  #cleanup
  sleep 5 && rm "$tmpfile"
}

let_my_swaps_go() {
  #tell linux to clear out swap; useful for long running desktop
  printf 'turning swap off...'
  sudo swapoff -a
  printf '... turning swap back on.'
  sudo swapon -a
}

#determine the newest file
# http://code.falconindy.com/cgit/dotfiles.git/plain/.functions
rlatest() {
  local count=${2:-1}

  find "${1:-.}" -type f -printf '%T@ %p\0' | sort -znr | {
    while (( count-- )); do
      read -rd ' ' _
      IFS= read -rd '' file
      printf '%s\n' "$file"
    done
  }
}

#eg.: notify me when a tarball is finally uploaded to dropox
# usage: URL [ READY_MESSAGE ]
notifyhttp() {
  local msg url retry
  retry=2

  url="$1"
  if [[ -z $url ]];then
    return 1
  fi

  msg="${2:-ready!}"
  while true; do
    curl -fI "$url" && {
      printf '%s\n' "$msg" ; break
    } || {
      printf '... URL failed, retrying in %s seconds.\n' "$retry"
      sleep "$retry"
    }
  done
}

# vim: et:ts=2:sw=2
