#!/usr/bin/env bash
# shellcheck shell=bash

read -r -d '' doc <<"EOF"
INSERT DOCO HERE

Arguments:
  -d|--debug = Enable debug mode, see commands but don't run (excludes passwords)
  --clowntown = bypass are you sure prompts

Usage:
  <replace> <devices file> <config to push>
  example_cmd ~/devices new_config
EOF

if [[ $# -eq 0 ]]; then
    echo "$doc"
    exit 1
fi

while :; do
  case $1 in
    --clowntown)
      _clowntown_mode=1
    ;;
    -d|--debug)
      _debug_mode=1
    ;;
    -?*)
      echo "ERROR: Unknown argument"
      echo "$doc"
      exit 1
    ;;
    *)
      break
  esac
  shift
done

# Start here

