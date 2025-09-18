#!/bin/bash

# this script is called by /etc/udev/rules.d/99-asus-bottom-screen.rules
# it passes the changing keyboard's state to the /tmp/zenbook/keyboard-status file

KEYBOARDFILE="/tmp/zenbook/keyboard-status"

case "$1" in
  1)
    echo "1" > "$KEYBOARDFILE"
    ;;
  0)
    echo "0" > "$KEYBOARDFILE"
    ;;
esac
