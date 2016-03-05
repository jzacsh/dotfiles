#!/bin/bash
#
# Originally copy/pasted from github.com/basilfx
#   git@gist.github.com:1ab94764f4d981f15e50.git at commit
#   fa9931b42eef30626d8d3cd
[ -z "$TMUX_PANE" == "" ] && exit 0 # Run only in tmux

set -e
declare -r tmxExec="$(readlink -f /usr/local/bin/tmux)"

# TODO bail earl if activity monitor is already on

irssiTmxDisp="$("$tmxExec" display -pt "$TMUX_PANE" '#S:#I' 2> /dev/null)"
[ -n "$irssiTmxDisp" ] || exit 0  # bail: irssi not attached to an X11 display

setMonitorTo() {
  "$tmxExec" set-window-option -t "$irssiTmxDisp" monitor-activity "$1" > /dev/null;
}

isTmxActive="$("$tmxExec" display -pt "$TMUX_PANE" '#{window_active}' 2> /dev/null)"
[ "$isTmxActive" == "0" ] || exit 0 # bail: tmux window is detached

# Print invis. char, triggering activity monitor., then disable it.
setMonitorTo on
echo -ne "\0"
setMonitorTo off
