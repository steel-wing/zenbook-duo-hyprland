#!/bin/bash

# this is a little script in charge of remembering the keyboard backlight state

BACKLIGHTFILE="/tmp/zenbook/backlight-status"

# build the backlight status file if it doesn't exist yet
mkdir -p "$(dirname "$BACKLIGHTFILE")"
touch "$BACKLIGHTFILE"

# read in the keyboard backlight status
read -r KB < "$BACKLIGHTFILE"
if [ -z "$KB" ]; then
  KB=0
  echo "$KB" > "$BACKLIGHTFILE"
fi

# reload the current backlight level
/usr/local/bin/zenbook-scripts/keyboard-backlight.py "$KB" &
