#!/bin/bash

# this script is called by /etc/udev/rules.d/99-zenbook-bottom-screen.rules
# it passes the changing keyboard's state to the /tmp/zenbook/zenbook-keyboard-status file

STATUSFILE="/tmp/zenbook/zenbook-keyboard-status"

# ensure the directory exists
mkdir -p "$(dirname "$STATUSFILE")"

case "$1" in
  1)
    echo "1" > "$STATUSFILE"
    ;;
  0)
    echo "0" > "$STATUSFILE"
    ;;
esac
