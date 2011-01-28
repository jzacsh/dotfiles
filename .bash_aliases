# aliases #####################
alias ls='ls --group-directories-first --color'
alias l='ls -laFH'
alias la='clear; ls -aFH'
alias ca='clear; ls -laFH'
alias cl='clear; ls -lFH'
alias diff='colordiff'
alias pfetch='drush cc all && drush -y fra && drush -y cc all && drush -y updb && hg push && hg stat'
alias mi="wget -qO- http://checkip.dyndns.org | sed -e 's/^.*Address:\ //' -e 's/<\/body.*//'"
alias tas="tmux attach-session"
alias tds="tmux detach-client"
alias udevinfo='udevadm info -q all -n'
alias mutt='pgrep mutt && mutt -R || mutt'
alias ipt="sudo iptraf"
alias goh="ssh home.jzacsh.com"
alias ak="source addkeys"

# x env #######################
alias br='$BROWSER'
alias ch='chromium-browser'
alias kflash='echo "killing flash..." && sudo killall npviewer.bin'
alias xt='xterm -bg black -fg white -maximized'
alias rx='rxvt -bg black -fg white -geometry 300x100 -face10'
alias urx='rxvt-unicode -bg rgba:1111/1111/1111/bbbb -fg white -fn "xft:Droid Sans Mono:pixelsize=10"'

# drupal contrib stuff ########
dcvs() {
  if [[ -z $1 ]];then
    echo -e "usage: dvcs module_name\n\tloads a drupal contrib module, module_name, from CVS HEAD." >&2
    return 1
  fi

  local module_name="$1"
  shift

  cvs -z6 -d:pserver:anonymous:anonymous@cvs.drupal.org:/cvs/drupal-contrib\
    checkout "contributions/modules/$module_name" ${@} #allow extra arguments
}

fu() {
  local dbg=
  if [[ $(echo ${1} | grep tar$) ]];then
    [[ $dbg ]] && echo "DEBUG: found tarball to be ${download}"
    local download=$1
  else
    echo -en 'usage: fu feature_name-X.x-#.#.tar\n'
    echo -en ' eg.: step 1: `cd /path/to/exact/feature/` \n'
    echo -en '      step 2: `cp /path/to/tarball .` \n'
    echo -en '      step 3: `fu ./name-of-tarball` \n'
    return 1
  fi

  echo -en 'unpacking feature: \n'
  tar xvf ${download}
  echo -en 'finished unpacking.\n'

  echo -en '\nupdating feature:\n'
  local feature=$(tar tf $download | sed -e '1s|/.*$|/|;q')
  # sanity check:
  local current="$(pwd | sed -e 's|.*/||g')/"
  if [[ $current != $feature ]]; then
      echo -en 'looks like you are unpacking in the WRONG directory....\n'
      echo -en "  feature being unpacked: $feature\n"
      echo -en "  your current directory: $current\n"
      echo -en 'Are you SURE you want to continue? [y/N] '; read answ
      [[ $answ == 'y' || $answ == 'Y' ]] || return 1
  fi
 
  [[ $dbg ]] && echo "DEBUG: found local directory to be: ${feature}"
  for file in $(find $feature -type f);do
    [[ $dbg ]] && echo "DEBUG: found local directory to be: ${feature}"
    mv -v $file $(echo $file | sed -e "s|$feature||")
  done
  echo -en 'finished updating.\n'

  echo -en "\njunk: ${feature} ${download} \n"
  echo -en 'cleanup junk, here? [Y/n] '; read answ
  if [[ $answ == 'n' || $answ == 'N' ]]; then
    return 0
  else
    rm -rfv ${download}
    rm -rfv ${feature}
  fi
}

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
wcat() ( wget -cqO- ${@} | $PAGER; )
hh() { wget -qS -O /dev/null ${@}; } #Http Headers

hgk() {
	hgview 2> /dev/null &
	disown
}

xfw() {
  DISPLAY=localhost:10 ${@}
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

dgo() {
  #see http://dgo.to/ for possible params
  local param="$1"
  local search="${*}"
  if [[ ${param:0:1} == "-" ]];then
    local key="$(echo $param | sed -e 's/.//')/"
    search="${@:2}"
  else
    local key='' #default search projects
  fi
  $BROWSER "http://dgo.to/${key}${search}"
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

# drupal stuff:
alias themer?='drush pm-list | grep -i "devel_themer"'

themer() {
  local nm='devel_themer'
  [[ $(drush pm-list | grep ${nm} | grep 'Enabled') ]] && drush -y dis ${nm} || drush -y en ${nm}
}

cleardd() {
  local uid
  # default values
  local def_file="/tmp/drupal_debug.txt"
  local def_uid="33" #uid for www-data

  # set values
  [[ -z ${1} ]] && echo "no params defaulting to: ${def_file}"
  local file=${1:-$def_file} #default param
  local file_uid=$(stat -c %u ${file} 2>/dev/null)
  [[ $file_uid -eq 0 ]] && unset file_uid #avoid root owned file
  uid=${file_uid:-$def_uid}

  # actual actions
  echo -e "using owner uid: ${uid}\n" #debug info
  file ${file} >&/dev/null && sudo rm -v ${file} #empty out existing file
  sudo -u#${uid} touch ${file} && tail -f ${file}
}

# export codez="~/code/web5-jzacsh/sites/all/modules/features/ ~/code/web5-jzacsh/sites/all/modules/custom/ ~/code/web5-jzacsh/sites/all/themes/zagat/"
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

## check which resources are loading #####################################################
#
# zcheck() {
#    if (( $# != 2 ));then
#       echo -e "usage:\tzcheck [css | js] url\n\teg.:zcheck css http://www.zagat.com/" >&2
#       return 1
#    fi
#    key=$1
#    url=$2
#
#    if [ $key == 'css' ]
#    then
#      narrow='link'
#    elif [ $key == 'js']
#    then
#        narrow='script'
#        key='javascript'
#    else
#      echo "ERROR: Improper key. Use 'css' or 'js'"
#      return 1
#    fi
#
#    echo "key is: $key"
#
#    wget -cqO- ${url} | grep 'zagat' | grep "${narrow}" | grep "${key}"
# }
