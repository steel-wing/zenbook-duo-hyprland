#!/bin/bash

# this script manages the keyboard backlight via keyboard-backlight.py

BACKLIGHTFILE="/tmp/zenbook/backlight-status"
read -r KB < "$BACKLIGHTFILE"

# if the file is empty, default to 0
if [ -z "$KB" ]; then
  KB=0
  echo "$KB" > "$BACKLIGHTFILE"
fi

case "$KB" in
  0)
    /usr/local/bin/zenbook-scripts/keyboard-backlight.py 1 &
    echo 1 > "$BACKLIGHTFILE"
    ;;
  1)
    /usr/local/bin/zenbook-scripts/keyboard-backlight.py 2 &
    echo 2 > "$BACKLIGHTFILE"
    ;;
  2)
    /usr/local/bin/zenbook-scripts/keyboard-backlight.py 3 &
    echo 3 > "$BACKLIGHTFILE"
    ;;
  3)
    /usr/local/bin/zenbook-scripts/keyboard-backlight.py 0 &
    echo 0 > "$BACKLIGHTFILE"
    ;;
esac
