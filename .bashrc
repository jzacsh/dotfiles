# If not running interactively, don't do anything
[[ ${-} = ${-/i/} ]] && return

umask 077

sourceExists() { [[ -s "$1" ]] || return 0; source "$1" ;}

# shell opts
shopt -s cdspell
shopt -s extglob
shopt -s histverify
shopt -s histappend
shopt -s no_empty_cmd_completion
shopt -s dirspell
set -o notify
set -o histexpand
set -o vi

# disable control character echoing
stty -ctlecho

# disable XON/XOFF flow control ("freeze" via ^q, ^s)
stty -ixon

# history options
export HISTIGNORE="&:ls:[bf]g:exit:hg in:hg out:reset:clear:ca:cl:l:cd*"
export HISTFILESIZE=20000
export HISTCONTROL='ignoreboth'
export HISTSIZE=5000

PROMPT_COMMAND='RET=$?' # see: man bash | less +/PROMPT_COMMAND
PS1='\s^$RET  @\t \w\n\u@\h   $SHLVL:\$ ' # vcprompt-less version of below
############################################################################
# $UID > 0 BELOW THIS LINE
#   everything above *should* be plain old shell options, nothing executable
[[ "$UID" -ne "0" ]] || return 0
############################################################################

PS1='\s^$RET  @\t $(vcprompt) \w\n\u@\h   $SHLVL:\$ ' # simple version of below
if [[ "$TERM" =~ 256color ]];then
  # vcs and color-aware version of bash prompt:
  set_fancy_ps1() {
    local col_end='\[\033[0m\]'
    local col_red='\[\e[1;31m\]'
    local col_grn='\[\e[0;32m\]'
    local col_grnB='\[\e[1;32m\]'
    local col_ylwB='\[\e[1;33m\]'
    local col_ylw='\[\e[0;33m\]'
    local col_blu='\[\e[1;34m\]'

    local col_usr=$col_grn
    if [[ "$UID" -eq "0" ]];then
      col_usr=$col_red #root's color
      alias vcprompt='echo -n' # don't execute `vcprompt`
    fi

    RET_VALUE='$(if [[ "$RET" -ne 0 ]];then echo -n ":\[\033[1;31m\]$RET\[\033[0m\]";fi)'
    PS1="${col_usr}\u@${col_end}${col_blu}\h${col_end}${RET_VALUE}"' \[\033[0;32m\]$(vcprompt)\[\033[0m\]'" ${col_ylwB}\w${col_end}\n\t  ${col_grnB}${SHLVL}${col_end}:${col_ylw}\$${col_end} "
    PS4='+$BASH_SOURCE:$LINENO:$FUNCNAME: '
  }
  set_fancy_ps1; unset set_fancy_ps1
fi

# $1=info|warn|err
log_jzdots() (
  local log_prefix level="$1" fmt="$2"; shift 2
  local col_start col_end='\033[0m'

  local log_lvl is_err=0
  case "$level" in
    info)
      log_lvl=INFO
      col_start='\e[0;38;5;81m'
      [[ "$TERM" =~ 256color ]] || col_start='\e[0;36m' # cyan (blue~ish)
      ;;
    warn)
      log_lvl=WARN
      col_start='\e[0;48;5;190;38;5;232m'
      [[ "$TERM" =~ 256color ]] || ccol_start='\e[0;33m' # yellow
      ;;
    *) # err; all else should be loud as it's just wrong
      is_err=1
      log_lvl="${level^^}"
      col_start='\e[5;4;38;5;196m\e[1m'
      [[ "$TERM" =~ 256color ]] || col_start='\e[0;31m' # red
      ;;
  esac

  log_prefix="${col_start}${log_lvl}${col_end}[~jzacsh/.]"
  if (( is_err ));then
    printf "$log_prefix"' '"$fmt" "$@" >&2
  else
    printf "$log_prefix"' '"$fmt" "$@"
  fi
)

log_jzdots info 'dircolors and other environment variables\n'
if [[ -r ~/.dircolors ]] && type dircolors >/dev/null 2>&1;then
  eval $(dircolors --bourne-shell ~/.dircolors)
fi
source ~/bin/share/zacsh_exports
if type systemctl >/dev/null 2>&1;then
  log_jzdots info 'detected systemd, importing environ\n'
  systemctl --user import-environment PATH
fi

log_jzdots info 'sourcing custom ~/.bash_aliases\n'
sourceExists ~/.bash_aliases

log_jzdots info 'walking ~/.host/ forrest...\n'
source $HOME/.host/pick  # Dynamic config

# in my nested tmux shells, my inherited `env` is old
dbusSessionBusAddress="$(cat ~/.dbus_address 2>/dev/null)"
if [[ "${dbusSessionBusAddress:-x}" != x ]] &&
   [[ "$DBUS_SESSION_BUS_ADDRESS" != "$dbusSessionBusAddress" ]];then
  if [[ -n "$DBUS_SESSION_BUS_ADDRESS" ]];then
    log_jzdots warn \
      'Blowing away _current_ $%s\n\tfrom: "%s"\n\t  to: "%s"\n' \
      DBUS_SESSION_BUS_ADDRESS \
      "$DBUS_SESSION_BUS_ADDRESS" "$dbusSessionBusAddress"
  else
    log_jzdots info \
      'resurrecting _some_ old $DBUS_SESSION_BUS_ADDRESS (%s) from ~/.dbus_address\n' \
      "$dbusSessionBusAddress"
  fi
  export DBUS_SESSION_BUS_ADDRESS="$dbusSessionBusAddress"
fi
unset dbusSessionBusAddress

# for irssi's notify.pl
[[ "${DBUS_SESSION_BUS_ADDRESS:-x}" = x ]] ||
  echo "$DBUS_SESSION_BUS_ADDRESS" > ~/.dbus_address

############################################################################
# External Configuration. Provided by libraries, etc.; not written by me, or
# widely standard.
############################################################################

[[ ! -e ~/.config/bash_completion.d/npm-run-completion.sh ]] &&
  npm completion > ~/.config/bash_completion.d/npm-run-completion.sh

sourceExists /etc/bash_completion
for completion in ~/.config/bash_completion.d/*.sh; do
  source "$completion"
done

# AWS's CLI completion provided via pip installer
sourceExists ~/.local/bin/aws_bash_completer

#must be after PATH:, apparently this will break if non-interactive shell `return`'s above.
sourceExists "$HOME/.rvm/scripts/rvm"

sourceExists ~/.hgbashrc

# autocompletion for man pages
source /usr/share/bash-completion/completions/man
complete -F _man -- mann

if type pip >/dev/null 2>&1; then
  source <(pip completion --bash)
fi

sourceExists ~/.fzf.bash

# Assumes you have ocaml setup, ie:
#   1) once: installed ocaml (and its pkg mgmt system, "opam", etc, etc.)
#   2) once: run `opam init`
#   3) optionally, once: installed vim ocaml things && `opam install ocp-indent`
sourceExists ~/.opam/opam-init/init.sh


################################################################################
# This section for things that might prompt me, which I might interrupt; if i do
# then the rest of my ~/.bashrc will not run
#
# Therefore anything below this sectino should be a nice-to-have only!
################################################################################

if [[ "${SSH_AUTH_SOCK:-x}" = x ]];then
  log_jzdots warn 'SSH_AUTH_SOCK empty, starting new agent\n'
  eval $(ssh-agent -s)
fi
for privKey in ~/.ssh/key.*[^pub];do
  ssh-add -l >/dev/null 2>&1 | grep "${privKey/$HOME\/}" >/dev/null 2>&1 ||
    ssh-add "$privKey"
done

######################################################
# Below this line is strictly for _messages_ to myself
######################################################

log_jzdots info 'DONE most of ~/.bashrc; just helpful messages below:\n'

# Highlight currently authenticated keys
ssh-add -l | grep --color=always --extended-regexp '^|\.ssh\/.*\ '
#NOTE: this should be first, since it always prints

# Users
if who | grep --invert-match "$(whoami)" > /dev/null; then
  printf '\nCurrently on %s, other than you:\n' "$(uname -snr)"
  who --heading | grep --invert-match "$(whoami)"
fi

#Laughs:
# curl --silent --location --connect-timeout 0.06 \
#     http://whatthecommit.com/index.txt 2>/dev/null

#Tmux
scowerForTmuxSessions() (
  [[ "${TMUX:-x}" = x ]] || return 0 # do not run inside tmux

  local firstPrinting=1
  local col_end='\033[0m'; local col_grn='\e[0;32m'
  local commonTmSocks=(default main "${USER}main")
  for sock in "${commonTmSocks[@]}"; do
    local tmSessions="$(tmux -L "$sock" list-sessions 2>/dev/null)"
    [[ "${tmSessions:-x}" != x ]] || continue

    if (( firstPrinting ));then
      havePrinted=0
      log_jzdots info 'found some tmux sessions (rettach via `tmux attach -t NAME`):\n'
    fi
    printf "tmux -L ${col_grn}%s${col_end} sessions:\n" "$sock"
    printf '%s\n' "$tmSessions" |
        GREP_COLORS='mt=01;33' \grep --color=always '^\w*:'
  done
)
scowerForTmuxSessions; unset scowerForTmuxSessions

# Print local mail waiting for me
scowerForMail() (
  local headers; headers="$(mail -H 2>&1)"
  if [[ "$?" -eq 0 ]];then
    local col_end='\033[0m'
    local col_red='\e[1;31m'

    echo -e '\n'$col_red'UNREAD'$col_end' messages; `mail` to read them:'
    printf '%s\n' "$headers"
  fi
)
scowerForMail; unset scowerForMail

# notify myself when degrated state
if type systemctl >/dev/null 2>&1 &&
  ! (systemctl --user --state=failed | grep -E '^0 loaded units'; ) >/dev/null 2>&1;then
  systemctl --user status
  printf -- 'Investigate with: %s\n' \
    'systemctl --user list-units --state=failed' >&2
fi

unset sourceExists
unset log_jzdots

true # don't assume last return status
