#!/usr/bin/env bash

[[ "$BASH_VERSINFO" -ge 4 ]] || {
  printf 'zOMG,omg this is below bashv4\n' >&2
  exit 1
}

# aliases #####################
alias ls='ls --color'
alias l='ls -laFH'
alias la='ls -aFH'
alias ca='clear; ls -laFH'
alias cl='clear; ls -lFH'
alias mi="curl -s http://checkip.dyndns.com | sed -e 's/^.*Address:\ //' -e 's/<\/body.*//'"
alias ipt='sudo iptraf'
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
alias eclimd='"$ECLIPSE_HOME"/eclimd'
alias pastie="$PASTIE"
alias json='python -mjson.tool'
# most commonly I'd like to convert: decimal <=> hex
alias tohex="printf '0x%x\n'"
alias fromhex="printf '%0.0f\n'"
alias beep=bell
alias e='$EDITOR'
alias csvpretty='column -t -s,' # eg: csvpretty < my.csv
alias pip=pip3

if type httpd >/dev/null 2>&1;then
  alias httpserve='httpd'
else
  alias httpserve='go run "$HOME"/bin/share/httpd.go'
fi

######################################
# preferred args/modes for given tools
alias diff='colordiff' # better diff ouput
alias grep='grep --color=auto' # better grep ouput
alias mutt='pgrep mutt && mutt -R || mutt' # single mutt PID management
type -p grc > /dev/null 2>&1 &&
  alias log='grc tail -F' # better tail
type -p node > /dev/null 2>&1 &&
  alias node='NODE_NO_READLINE=1 rlwrap node' # better node repl
alias git_log='git log --patch --graph' # better `git log`
alias git_diff_sbs='git difftool --no-prompt --extcmd="colordiff --side-by-side --width $COLUMNS" | ${PAGER:-less}'

# x env #######################
alias fixcaps='setxkbmap -option ctrl:swapcaps' # swaps caps with right-control

######################################
## typos; common spelling mistakes ###
alias vi='nvim'
alias les='less'
alias duff='echo "no beer here, try \`diff\`."'
alias :w='echo "yeahh... this is not [n]vim." >&2'
alias :q=':w'
alias :e=':w'
alias :x=':w'
alias gt='git'
# prefixes to display-sensitive commands (tmux/ssh/console considerations)
alias xf='DISPLAY=localhost:10.0 '
alias xl='DISPLAY=:0.0 ' #eg: `xl xdg-open ./my.pdf`

# taking notes in a meeting or lecture, instead of futtzing around with my
# gnome popdown calendar and navigating through months, or sleeping my notes and
# running `cal -3`
alias notes='"$EDITOR" +":Calendar -view=year -width=27 -split=vertical"'

############
# one liners
chars() ( sed -e 's/\(.\)/\1\n/g'; )
tarl() ( tar -tf ${*}  | $PAGER; )
ident() ( identify -verbose $1 | grep modify; )
geo() ( identify -verbose $1 | grep geometry; )
wat() ( curl -Ls ${@} | $PAGER; )
favipng() (
  set -euo pipefail
  local faviUrl
  faviUrl="$(curl -Ls "$@" | pup 'link[rel="icon"] attr{href}')"
  if [[ "${faviUrl:-x}" = x ]];then
    printf "Could not parse favicon from site's markup\n" >&2
    return 1
  fi
  local ext; ext="$(basename "$faviUrl")"; ext="${ext##*.}"
  local out; out="$(mktemp --tmpdir=. "favipng_XXXXX.${ext}")"

  ( set -x; curl -Ls "$faviUrl" > "$out"; )
  echo "$out"
)
mdown() ( markdown_py < /dev/stdin | html; )  # depends on html alias above
clock() ( while true; do printf '\r%s ' "$(date --iso-8601=ns)";done; ) # watch a running clock
tree() ( find -O3 $@ | sort; )
pcLog() (
  local t=tail
  if type grc >/dev/null 2>&1;then t='grc tail';fi
  $t -F -n 50 /var/log/{dmesg,udev,{sys,ufw.,kern.auth.}log} ~/usr/log/*.log
)
zpdf() ( zathura "$1" >/dev/null 2>&1 & disown; )

# bump font on the fly; from https://bbs.archlinux.org/viewtopic.php?id=44121
urxvtc_font() { printf '\33]50;%s%d\007' "xft:Terminus:pixelsize=" $1; }

# (nice defaults) silversearcher-style; assume i want to grep all local files
type ag >/dev/null 2>&1 || ag() (
  (( $# )) || { printf 'usage: REGEXP [FILE|DIR]\n' >&2; return 1; }
  \grep --color=auto --recursive --line-number "$@"
  # grep(1): "Note that if no file operand is given, grep searches the working directory."
)

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
cliMock() ( printf '$ %s\n%s\n\n' "$*" "$(bash -c "$*" 2>&1)"; );

gnome-background() (
  set -euo pipefail

  local fileUri; printf -v fileUri 'file://%s' "$(readlink -f "$1")"

  # found dconf URI in http://askubuntu.com/a/510135/426803
  gsettings set org.gnome.desktop.background picture-uri "$fileUri"
)

keyboard() (
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
)

#`hg shelve` extension is broken for some reason.
hgunshelve () (
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
)

# `dict`, but treat args just as `echo` does, and add highlighting
define() {
  dict "$*" |
    grep --ignore-case --color=always --extended-regexp '^|'"$*" |
    less -LINE-NUMBERS
}

#dictionary look ups
lu() (
  local lang=en; # default
  if [[ "${LANG:-x}" != x ]] && [[ -n "${LANG/_*/}" ]];then
    lang="${LANG/_*/}"
  fi

  [[ "$#" -eq 1 ]] || { printf 'usage: WORD\n' >&2; return 1; }

  local target="$1"
  curl --silent --location "https://${lang}.wiktionary.org/wiki/$target" |
    w3m -dump -T text/html |
    grep --color=always --extended-regexp '^|\b'"$target"'\b' |
    "${PAGER:-less}"
)

#translate
trans() (
  local orig="$1"
  local targ="$2"
  shift;shift
  local text="$*"
  local google_api='http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q='
  local url="${google_api}${text// /+}&langpair=${orig}|${targ}"
  curl ${url} 2>/dev/null #| sed 's/.*"translatedText":"\([^"]*\)".*}/\1\n/'
)

# List the newest N(="$2")-files in directory "$1"
rlatest() (
  local count=${2:-1}

  find "${1:-.}" -type f -printf '%T@ %p\0' | sort -znr | {
    while (( count-- )); do
      read -rd ' ' _
      IFS= read -rd '' file
      printf '%s\n' "$file"
    done
  }
)

#eg.: notify me when a tarball is finally uploaded to dropox
# usage: URL [ READY_MESSAGE ]
notifyhttp() (
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
)

html() (
  if type w3m >/dev/null 2>&1; then
    w3m -dump -T text/html
  elif type lynx >/dev/null 2>&1; then
    lynx -force_html -stdin -dump -nolist
  else
    printf 'error: no lynx or w3m to parse HTML with\n' >&2
    return 1
  fi
)

whiteboardify() (
  [[ "$#" -eq 2 ]] || {
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
)

# java-repl: make it easy for myself to remember this exists...
#   https://github.com/albertlatacz/java-repl
javacli() (
   local repo="$HOME"/media/src/java-repl
   [[ -e "$repo" && -r "$repo" && -d "$repo" ]] || {
     printf \
       'warning: did not find readable dir at; clone it?...\n\t%s\n' \
       "$repo" >&2
     return 1
   }
   local replJar="$repo"/build/libs/javarepl-dev.jar
   [[ -r "$replJar" ]] || {
     printf \
       'warning: did not find java-repl jar; build it?\n\t%s\n' \
       "$replJar" >&2
     return 1
   }
   java -jar "$replJar"
)

baseFromTo() (
  local quiet=0
  if [[ "$#" = 4 ]];then
    [[ "$1" = -q ]] || {
      printf 'usage: [-q] FROM TO FROM_VALUE\n' >&2
      return 1;
    }
    shift; quiet=1;
  fi
  local fro="$1"
  local to="$2"
  shift 2
  (( quiet )) || set -x
  printf -- 'obase=%d; ibase=%d; %s\n' "$to" "$fro" "${*^^}"  | bc
)

#########################################
# `mktemp` wrappers/workflows ###########

_assertEnvVariable() {
  [ -n ${!1} ] && return 0
  printf 'Error: $%s env. variable not set\n' "$1" >&2
  return 1
}

_collectWithEditor() (
  _assertEnvVariable EDITOR || return 1

  local contentName="$1"
  local tdir="$2"

  local when; when="$(
    date --iso-8601=minutes |
      sed -e 's|:|.|g' -e 's|-||g'
  )"
  local tmpl; tmpl="$(printf '%s_%s-from-EDITOR_XXXXXXX.txt' "$when" "$contentName")"
  local tmpfile; tmpfile="$(
    if [ -z "${2/ */}" ];then
      mktemp --tmpdir      "$tmpl"
    else
      mktemp --tmpdir="$tdir" "$tmpl"
    fi
  )"

  [ -w "$tmpfile" ] || {
    printf 'failed to open a writeable temporary file\n' >&2
    return 1
  }

  {
    "$EDITOR" "$tmpfile" < /proc/"$$"/fd/0 > /proc/"$$"/fd/1 &&
      [ "$(stat --printf='%s' "$tmpfile")" != 0 ];
  } || return $?

  printf '%s' "$tmpfile"
  return 0
)

tmp_to_pastie() (
  local contentF; contentF="$(_collectWithEditor pastie)"
  [ $? -ne 0 ] && return 1

  local pastieExit=0
  if [ -n "$1" ] && { [ "$1" = c ] || [ "$1" = -c ]; } then
    _assertEnvVariable BROWSER || return 1
    "$BROWSER" "$contentF"; pastieExit=$?      # paste with clipboard/x11
  else
    _assertEnvVariable PASTIE || return 1
    "$PASTIE" $@ < "$contentF"; pastieExit=$?  # use proper pastebin
  fi

  if [ $pastieExit -ne 0 ];then
    printf 'ERROR: failed to pastie contents of:\n\t%s\n' "$contentF" >&2
    return $pastieExit
  fi

  rm "$contentF"
)

vmail() (
  local contentF; contentF="$(_collectWithEditor vmail)"
  [ $? -ne 0 ] && return 1

  if \mail $@ < "$contentF";then
    printf 'ERROR: failed to mail contents of:\n\t%s\n' "$contentF" >&2
    return 1
  fi

  rm "$contentF"
)

tmp_encrypt_mail() (
  _assertEnvVariable EMAIL || {
    printf 'Error: need your key uid to sign with' >&2
    return 1
  }

  { [ $# -ne 0 ] && [ "$1" != "$EMAIL" ]; } || {
    printf 'Error: expected emails whose public keys should be signed with\n' >&2
    return 1
  }

  local msgF; msgF="$(_collectWithEditor unencrypted-msg-for-gpg ./)"
  [ $? -ne 0 ] && return 1

  local recips; recips=($@); recips+=("$EMAIL")
  local recipArgs; recipArgs="$(printf ' --recipient %s ' ${recips[@]})"

  printf \
    'Clear message composed in:\n\t%s\nEncrypting its contents for:\t%s\n\n' \
    "$msgF" "${recips[*]}"
  set -x
  gpg --sign --armor $recipArgs --encrypt "$msgF"
)

mkScratchDir() (
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
)
scratchDir() { pushd "$(mkScratchDir $@)"; }

vid_get_duration() (
  avconv -i "$1" 2>&1 |
      grep Duration |
      sed -e 's|.*Duration:\ \(.*$\)|\1|' |
      cut -f 1 -d ' ' |
      sed -e 's|,$||g'
)

vid_to_gif() (
  set -e

  if [[ "$#" -ne 2 && "$#" -ne 3 ]]; then
    printf 'usage: [-k] SRC_VIDEO OUT_GIF\n' >&2
    printf '  -k: keep temporary files used during construction\n' >&2
    return 1
  fi

  local keepScraps=0
  if [[ "$#" -eq 3 ]];then
    [[ "$1" = -k ]] || {
      printf 'unexpected second arg in 3-arg call; try zero-arg for help\n' >&2
      return 1
    }
    keepScraps=1
    shift
  fi

  local inVid="$(readlink -f "$1")";
  [ -n "$inVid" ]; [ -r "$inVid" ]; [ -f "$inVid" ];

  local outGif="$2"
  if [ -z $outGif ];then outGif="$(dirname "$inVid")"/out.gif; fi

  local framesDir="$(mktemp --directory --tmpdir 'vid-to-gif_frames_XXXXXXX')"
  [ -n "$framesDir" ]

  # Figure out *which* utility to use
  local vidExec vfArgs
  local scale=900
  if type avconv > /dev/null 2>&1;then
    vidExec=avconv
    vfArgs="scale=${scale}:-1:flags=lanczos -r 10"
  elif type ffmpeg > /dev/null 2>&1;then
    vidExec=ffmpeg
    vfArgs="scale=${scale}:-1:flags=lanczos,fps=10"
  else
    printf 'ERROR: could not find `ffmpeg` or `avconv` utilities\n' >&2
    return 1
  fi

  printf '[STEP 1 of 3]\tExporting frames from "%s"\n' "$inVid"
  time { "$vidExec" -loglevel quiet -i "$inVid" -vf $vfArgs "$framesDir"/ffout%03d.png; }

  printf '[STEP 2 of 3]\tCompiling frames into single GIF in "%s"\n' "$outGif"
  time { convert -loop 0 "$framesDir"/ffout*.png "$outGif"; }

  if (( keepScraps ));then
    printf '[STEP 3 of 3]\tLeaving frames and temp dir intact:\n\t"%s"\n' "$framesDir"
  else
    printf '[STEP 3 of 3]\tCleaning up frames and temp dir:\n\t"%s"\n' "$framesDir"
    rm "$framesDir"/*.png
    rmdir "$framesDir"
  fi
)

# vim: et:ts=2:sw=2
