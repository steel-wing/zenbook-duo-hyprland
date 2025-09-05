#!/bin/bash

# this script is called by /etc/udev/rules.d/99-zenbook-bottom-screen.rules
# it passes the changing keyboard's state to the zenbook-keyboard-status file

STATUSFILE="/tmp/zenbook/zenbook-keyboard-status"

# Ensure the directory exists
mkdir -p "$(dirname "$STATUSFILE")"

case "$1" in
  off)
    echo of > "$STATUSFILE"
    ;;
  on)
    echo on > "$STATUSFILE"
    ;;
esac
