#!/usr/bin/env bash
# Taken from https://www.reddit.com/r/tmux/comments/hcbhlr/cannot_setenv_in_tmuxconf_on_centos_7/fvhgylj/

tmux="$(lsof -a -d txt -c /^tmux$/ | grep 'tmux$' | rev | cut -f1 -d' ' | rev | uniq)"

# Exit if the TMUX_VERSION is already set in the environment.
if ${tmux} show-environment -g | grep TMUX_VERSION &>/dev/null; then
  exit
fi

# Determine the version number, which could have any of these forms:
#   1.8
#   2.4
#   3.1b
#   next-3.2
#   ...etc...
version="$("${tmux}" -V | grep -Eo '[0-9\.]*')"

# Set the variable in all sessions.
${tmux} set-environment -g TMUX_VERSION "${version}"
