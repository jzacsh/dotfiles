# aliases #####################
set +o histexpand
set -o vi
alias ls='ls --group-directories-first --color'
alias l='ls -laFH'
alias la='clear; ls -aFH'
alias ca='clear; ls -laFH' 
alias cl='clear; ls -lFH'
alias diff='colordiff'
alias pfetch='drush cc all && drush -y fra && drush -y cc all && drush -y updb && hg push && hg stat'
alias mi="wget -qO- http://checkip.dyndns.org | sed -e 's/^.*Address:\ //' -e 's/<\/body.*//'"
alias tas="tmux attach-session"

# x env #######################
alias m='nautilus --browser'
alias ff='firefox'
alias gc='google-chrome'
alias kflash='sudo killall npviewer.bin'
alias rw="echo 'rebooting mysql and apache' && sudo service apache2 restart && sudo service mysql restart"
alias xt='xterm -bg black -fg white -maximized'
alias rx='rxvt -bg black -fg white -geometry 300x100 -face10'
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
  str='dropbox start'
  stp='dropbox stop'
  sta='dropbox status'
  $stp
  $str
  $sta
  for i in {1..5}; do sleep 1 && $sta; done
  for i in {1..15}; do sleep 2 && $sta; done
}

###############################
# functions ###################
ident() ( identify -verbose $1 | grep modify; )
g() ( IFS=+; $BROWSER "http://www.google.com/search?q=${*}"; )

### zagat specific: ###########
hgk() {
	hgview 2> /dev/null &
	disown
}

newrepo() {
  conf="$HOME/code/conf/web5"
  repo="$HOME/code/web5-jzacsh"
  cd $repo/sites/
    [[ $? -ne 0 ]] && echo 'FAILURE: unsuccessful local repo linking' && return 1
  ln -s $conf/default
    [[ $? -ne 0 ]] && echo 'FAILURE: unsuccessful local repo linking' && return 1
  cd $repo/sites/all/modules
    [[ $? -ne 0 ]] && echo 'FAILURE: unsuccessful local repo linking' && return 1
  ln -s $conf/local
    [[ $? -ne 0 ]] && echo 'FAILURE: unsuccessful local repo linking' && return 1
  cd $repo
  echo -e 'SUCCESS: Finished linking local settings to Drupal repo.'
  ls -laFh
}

tarl() ( tar -tf ${*}  | less; )

beans() ( /usr/local/netbeans-6.9/bin/netbeans $* & disown 2> /dev/null; )

xdebug() ( $BROWSER ${1}?XDEBUG_SESSION_START=1; )
xdbgstp() ( $BROWSER ${1}?XDEBUG_SESSION_STOP=1; )

hc() ( hg commit -m ${1}; )

hgdiff() ( hg cat $1 | vim - -c  ":vert diffsplit $1" -c "map q :qa!<CR>"; )

alias themer?='drush pm-list | grep -i "devel_themer"'
alias cleardd='sudo rm -v /tmp/drupal_debug.txt  && sudo -u www-data touch /tmp/drupal_debug.txt'

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
