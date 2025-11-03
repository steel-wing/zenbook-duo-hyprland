#!/bin/bash

# this script toggles the visibility of wvkbd when called, SUPER + A is default
# credit to a deleted user on reddit from 2023 for this one 

# load up our context
KEYBOARDFILE="/tmp/zenbook/keyboard-status"
ORIENTFILE="/tmp/zenbook/orientation-status"
read -r STATUS < "$KEYBOARDFILE"
read -r ORIENTATION < "$ORIENTFILE"

if [[ "$STATUS" == "1" ]]; then
    exit 0
fi

# get the PIDs of wvkbd
WVKBD_PIDs=$(pgrep -x "wvkbd-zenbook")

if [ -z "$WVKBD_PIDs" ]; then
    hyprctl dispatch focusmonitor eDP-2
    sleep 0.1
    wvkbd-zenbook -H 400 -L 580 &

else
    sleep 0.1
    for pid in $WVKBD_PIDs; do
        # -34 = SIGRMIN, so, toggle visibility
        kill -34 $pid
    done
fi