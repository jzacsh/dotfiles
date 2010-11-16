# aliases #####################
set +o histexpand
set -o vi
alias ls='ls --group-directories-first --color'
alias l='ls -laFH'
alias la='clear; ls -aFH'
alias ca='clear; ls -laFH' 
alias cl='clear; ls -lFH'
alias diff='colordiff'
alias nc='ncmpcpp'
alias pfetch='drush cc all && drush -y fra && drush -y cc all && drush -y updb && hg push && hg stat'
alias mi="wget -qO- http://checkip.dyndns.org | sed -e 's/^.*Address:\ //' -e 's/<\/body.*//'"
alias tas="tmux attach-session"
alias cower='cower -c'
alias udevinfo='udevadm info -q all -n'
alias rw="echo 'rebooting interwebs (mysql and apache)' && sudo service apache2 restart && sudo service mysql restart"
alias mutt='pgrep mutt && mutt -R || mutt'
alias ipt="sudo iptraf"

# x env #######################
alias m='nautilus --browser'
alias br='$BROWSER'
alias ch='chromium-browser'
alias kflash='echo "killing flash..." && sudo killall npviewer.bin'
alias xt='xterm -bg black -fg white -maximized'
alias rx='rxvt -bg black -fg white -geometry 300x100 -face10'
alias urx='rxvt-unicode -bg rgba:1111/1111/1111/bbbb -fg white -fn "xft:Droid Sans Mono:pixelsize=10"'
alias djo="alias djo-admin='/srv/http/subs/ofas/inc/djo/django/bin/django-admin.py'"

# DRUPAL CONTRIB STUFF ########
# export CVSROOT=:pserver:jzacsh@cvs.drupal.org:/cvs/drupal-contrib
# grab latest HEAD from cvs:
alias dcup='cvs -z6 -d :pserver:anonymous:anonymous@cvs.drupal.org:/cvs/drupal checkout drupal'

## common spelling mistakes ###
alias les='less'
alias office='ooffice'

## dropbox can suck: ##########
dropx() {
  db="dropbox"
  for act in {op,art,atus}; do $db st${act}; done
  for i in {1..5}; do sleep 1 && $db status; done
  for i in {1..15}; do sleep 2 && $db status; done
}

###############################
# functions ###################
lu() ( dict ${@} | less; )

xfw() {
  DISPLAY=localhost:10 ${@}
}

speak() { echo ${@} | espeak 2>/dev/null; }

ident() ( identify -verbose $1 | grep modify; )
g() ( IFS=+; $BROWSER "http://www.google.com/search?q=${*}"; )

xdb() {
  uri_append='?XDEBUG_SESSION_STOP'
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
  param="$1"
  search="${*}"
  if [[ ${param:0:1} == "-" ]];then
    key="$(echo $param | sed -e 's/.//')/"
    search="${@:2}"
  else
    key='' #default search projects
  fi
  $BROWSER "http://dgo.to/${key}${search}"
}

tmp() {
  if [[ $1 == 'c' ]]; then
    $EDITOR ~/tmp/bl && $BROWSER ~/tmp/bl && rm ~/tmp/bl
  else
    $EDITOR ~/tmp/bl && dpaste < ~/tmp/bl && rm ~/tmp/bl
  fi
}

gencscope() {
  if [[ $(uname -n) == "jznix" ]];then
    local DIRS=(/srv/http/subs/notes/www/{sites/all/{modules/contrib,themes},includes,modules})
  else
    local DIRS=(~/code/web5-jzacsh/{sites/all/{modules/contrib,themes},includes,modules})
  fi
  cscope -b -i <(find "${DIRS[@]}" \( -name '*.inc' -or -name '*.php' -or -name '*.module' \))
}

### zagat specific: ###########
hgk() {
	hgview 2> /dev/null &
	disown
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

fu() {
  local dbg=
  if [[ $(echo ${1} | grep tar$) ]];then
    [[ $dbg ]] && echo "DEBUG: found tarball to be ${download}"
    download=$1 
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
  dirname=$(tar tf $download | sed -e '1s|/.*$|/|;q')
  [[ $dbg ]] && echo "DEBUG: found local directory to be: ${dirname}"
  for file in $(find $dirname -type f);do 
    [[ $dbg ]] && echo "DEBUG: found local directory to be: ${dirname}"
    mv -v $file $(echo $file | sed -e "s|$dirname||")
  done
  echo -en 'finished updating.\n'

  echo -en "\njunk: ${dirname} ${download} \n"
  echo -en 'cleanup junk, here? [Y/n] '
  read answ
  if [[ $answ == 'n' || $answ == 'no' ]]; then
    return 0
  else
    rm -rfv ${download}
    rm -rfv ${dirname} 
  fi
}

newcny() {
  vb=1
  loc=$(uname -n)
  conf="$HOME/code/conf/web5"
  repo="$HOME/code/web5-jzacsh"
  [[ $vb ]] && echo -e '\ninserting link to local-only modules'
  ln -sv $conf/local $repo/sites/all/modules/local
  [[ $vb ]] && echo -e '\ninserting link to "default" directory'
  ln -sv $conf/default $repo/sites/default
  $BROWSER "http://${loc}.zagat.com/"
}

tarl() ( tar -tf ${*}  | less; )

beans() ( /usr/local/netbeans-6.9/bin/netbeans $* & disown 2> /dev/null; )

hc() ( hg commit -m ${@}; )

hgdiff() ( hg cat $1 | vim - -c  ":vert diffsplit $1" -c "map q :qa!<CR>"; )

alias themer?='drush pm-list | grep -i "devel_themer"'

cleardd() {
  def_file="/tmp/drupal_debug.txt"
  def_usr="33"
  [[ -z ${1} ]] && echo "no params defaulting to: ${def_file}" || file="${1}"
  [[ -z ${file} ]] && file="${def_file}"
  usr=$(stat -c %u ${file} || echo ${def_usr})
  echo -e "owner of ${file} is: ${usr}\n" #debug info
  sudo rm -v ${file}
  sudo -u#${usr} touch ${file} && tail -f ${file}
}

# export codez="~/code/web5-jzacsh/sites/all/modules/features/ ~/code/web5-jzacsh/sites/all/modules/custom/ ~/code/web5-jzacsh/sites/all/themes/zagat/"
origrm() {
  if [[ $1 == "-n" ]]; then
    opt='-delete -print'
  else
    opt=''
  fi

  find ~/code/web5-jzacsh/ -name '*.orig' ${opt}
}

themer() {
  nm='devel_themer'
  [[ $(drush pm-list | grep ${nm} | grep 'Enabled') ]] && drush -y dis ${nm} || drush -y en ${nm}
}

mp() {
#  echo "smb://$(echo ${*} | sed -e 's/\\/\//g' | sed -e 's/\ /\\\ /g')"
  echo smb://$(echo "${*}" | sed -e 's/\\/\//g' | sed -e 's/\ /\\\ /g')
}

# zcheck() {
#    [[ $# -eq 0 ]] && echo -e "usage:\tzcheck [css | js] url\n\teg.:check css http://www.zagat.com/" && return 1
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
