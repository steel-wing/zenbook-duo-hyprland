#!/bin/bash

# this script toggles the visibility of wvkbd when called, SUPER + A is default
# credit to a deleted user on reddit from 2023 for this one

# load up our context
KEYBOARDFILE="/tmp/zenbook/keyboard-status"
ORIENTFILE="/tmp/zenbook/orientation-status"
read -r STATUS < "$KEYBOARDFILE"
read -r ORIENTATION < "$ORIENTFILE"

# get out of here if we aren't vertical or the keyboard isn't off
if [[ "$STATUS" == "1" || "$ORIENTATION" != "0" ]]; then
    exit
fi

# Save the current IFS
OLD_IFS=$IFS

# Set IFS to newline
IFS=$'\n'

# Get the PIDs of wvkbd
WVKBD_PIDs=$(pgrep -x "wvkbd-zenbook")


# see about using the signals for this instead?


# Check if wvkbd is running
if [ -z "$WVKBD_PIDs" ]; then
    # wvkbd is not running, so start it
    hyprctl dispatch focusmonitor eDP-2
    sleep 0.1
    wvkbd-zenbook -H 600 -L 600 &

else
    # wvkbd is running, so toggle its visibility for each PID
    sleep 0.1
    for pid in $WVKBD_PIDs; do
        kill -34 $pid
    done
fi

# Restore the original IFS
IFS=$OLD_IFS