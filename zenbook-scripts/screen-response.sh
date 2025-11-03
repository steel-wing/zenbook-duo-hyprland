#!/bin/bash

# this script runs during startup and after opening the lid
# it ensures that the bottom monitor reflects the physical status of the keyboard

TARGET_ID=0b05:1b2c # lsusb id of zenbook keyboard
KEYBOARDFILE="/tmp/zenbook/keyboard-status"

# very silly way of getting around hyprland glitching issues after reload
sleep 0.5

if lsusb | grep -q "$TARGET_ID"; then       # we're doing this instead of the udev so that if the keyboard changes states while we weren't looking,
    echo "1" >"$KEYBOARDFILE"               # this will still ensure everything gets connected correctly
else
    echo "0" >"$KEYBOARDFILE"
fi

/usr/local/bin/zenbook-scripts/update-screens.sh &