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
alias grep='grep --color=auto'
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
alias o='xdg-open'
alias lint='lintch'
alias pfresh='pfresh -w'
alias eclimd='"$ECLIPSE_HOME"/eclimd'
alias vim='vim -X'
alias html='w3m -dump -T text/html'
alias pastie="$PASTIE"
alias json='python -mjson.tool'
alias log='grc tail -F'
alias git_diff_sbs='git difftool --no-prompt --extcmd="colordiff --side-by-side --width $COLUMNS" | ${PAGER:-less}'

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
rfc() { curl -Ls "http://tools.ietf.org/rfc/rfc${1}.txt" | ${PAGER:-less}; }
hgchanged() { hg -q in ${1} --template='{files}\n'; }
mdown() { markdown_py < /dev/stdin | html; }  # depends on html alias above

# bump font on the fly; from https://bbs.archlinux.org/viewtopic.php?id=44121
urxvtc_font() { printf '\33]50;%s%d\007' "xft:Terminus:pixelsize=" $1; }

# poor man's asciinema. helpful for pasting commands used and their output in a single pipe
#
# Usage: COMMAND_LINE
#
# Example, assuming `you@machine` is your real shell prompt:
#   you@machine$ cliMock lsb_release --all
#
#   $ lsb_release --all
#   No LSB modules are available.
#   Distributor ID: Debian
#   Description:    Debian GNU/Linux testing-updates (sid)
#   Release:        testing-updates
#   Codename:       sid
#
# Example, more likely:
#   $ lsb_release --all | pastie # win
cliMock() { printf '$ %s\n%s\n\n' "$*" "$($@ 2>&1)"; };

keyboard() {
# NOTE: step #1 might not be necessary, perhaps bluez just expects a PIN typed
# identically in both places. will try to clarify next time.
  cat <<EO_INSTRUCTION
assuming:
  a) \`bluez\` and \`hidd\` exists; respectively: apt-get install bluez bluez-compat
  b) a "DisableSecurity" line lives in /etc/bluetooth/network.conf
  c) KEYBOARD_ID is of format XX:XX:XX:XX:XX:XX (eg: "08:B7:38:12:B6:CA")
     find via: \`bluez-test-discovery\`

1) disable security, via /etc/bluetooth/network.conf
2) pair: \`bt-device --connect=KEYBOARD_ID\`
   a) type "0000⏎" at prompt (ie: here, on host)
   b) enter "0000⏎" on bluetooth keyboard (and step #2 should return 0)
3) connect: \`sudo hidd --connect KEYBOARD_ID\`
4) cleanup step #1
EO_INSTRUCTION
}

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
    "$EDITOR" "$tmpfile" && "$PASTIE" "$@" < "$tmpfile"
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

mkScratchDir() {
  local keyword="${1:-scratch}"

  local tmpDir=~/tmp/build/

  local when
  when="$(
    date --iso-8601=minutes |
      sed -e 's|:|.|g' -e 's|-||g'
  )"

  local mktempTemplate
  mktempTemplate="${when}_$(whoami)_${keyword}-dir_XXXXXXXX"

  local newTmpDir
  if [ -d "$tmpDir" ];then
    newTmpDir="$(mktemp -d --tmpdir="$tmpDir" "$mktempTemplate")"
  else
    newTmpDir="$(mktemp -d --tmpdir "$mktempTemplate")"
  fi

  printf '%s\n' "$newTmpDir"
}

scratchDir() { pushd "$(mkScratchDir $@)"; }

vid_get_duration() {
  avconv -i "$1" 2>&1 |
      grep Duration |
      sed -e 's|.*Duration:\ \(.*$\)|\1|' |
      cut -f 1 -d ' ' |
      sed -e 's|,$||g'
}

vid_to_gif() (
  set -e

  local inVid="$(readlink -f "$1")"; [ -r "$1" ]; [ -f "$1" ];
  local outGif="$(dirname "$inVid")"/"${2:-out.gif}"
  local framesDir="$(mktemp --directory --tmpdir 'vid-to-gif_frames_XXXXXXX')"

  # Figure out *which* utility to use
  local vidExec vfArgs
  if type avconv > /dev/null 2>&1;then
    vidExec=avconv
    vfArgs="scale=320:-1:flags=lanczos -r 10"
  elif type ffmpeg > /dev/null 2>&1;then
    vidExec=ffmpeg
    vfArgs="scale=320:-1:flags=lanczos,fps=10"
  else
    printf 'ERROR: could not find `ffmpeg` or `avconv` utilities\n' >&2
    return 1
  fi

  printf '[STEP 1 of 3]\tExporting frames from "%s"\n' "$inVid"
  "$vidExec" -loglevel quiet -i "$inVid" -vf $vfArgs "$framesDir"/ffout%03d.png

  printf '[STEP 2 of 3]\tCompiling frames into single GIF in "%s"\n' "$outGif"
  convert -loop 0 "$framesDir"/ffout*.png "$outGif"

  printf '[STEP 3 of 3]\tCleaning up frames and temporary directory "%s"\n' "$framesDir"
  rm "$framesDir"/*.png
  rmdir "$framesDir"
)

whiteboardify() {
  [ $# -eq 2 ] || {
    echo "usage: IN_FILE OUT_FILE
      to generate a whiteboardified version of INFILE
      and write it to OUTFILE" >&2
    return 1
  }
  convert "$1" \
    -morphology Convolve DoG:15,100,0 \
    -negate \
    -normalize \
    -blur 0x1 \
    -channel RBG \
    -level 60%,91%,0.1 \
    "$2"
}

# vim: et:ts=2:sw=2
