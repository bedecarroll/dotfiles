#!/usr/bin/env bash
# Taken from https://www.reddit.com/r/tmux/comments/hcbhlr/cannot_setenv_in_tmuxconf_on_centos_7/fvhgylj/

# Get the tmux server PID.
tspid="$(pstree --arguments --show-pids \
  | grep --extended-regexp --only-matching 'tmux(: server)?,[0-9]+' \
  | grep --extended-regexp --only-matching '[0-9]+' \
  | head -n 1 \
  | tr --delete ' ' \
  )"

# Get the tmux command, as observed from procfs.  Since this uses procfs, this
# may not work on Mac OSX, so YMMV.
tmux="$(readlink --canonicalize "/proc/${tspid}/exe")"

# Exit if the TMUX_VERSION is already set in the environment.
${tmux} show-environment -g | grep TMUX_VERSION &>/dev/null
if [[ "${?}" -eq 0 ]] ; then
  exit
fi

# Determine the version number, which could have any of these forms:
#   1.8
#   2.4
#   3.1b
#   next-3.2
#   ...etc...
version="$("${tmux}" -V | grep -Po '[0-9\.]*')"

# Set the variable in all sessions.
${tmux} set-environment -g TMUX_VERSION "${version}"
