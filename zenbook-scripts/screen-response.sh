#!/bin/bash

# this script runs during startup and after opening the lid
# it ensures that the bottom monitor reflects the physical status of the keyboard

TARGET_ID=0b05:1b2c # lsusb id of zenbook keyboard
STATUSFILE="/tmp/zenbook/keyboard-status"

# very silly way of getting around hyprland issues after reload
sleep 0.5

### Load Keyboard Status ###

if lsusb | grep -q "$TARGET_ID"; then       # we're doing this instead of reading so that if, somehow, the keyboard were to change
    echo "1" >"$STATUSFILE"                 # states while we weren't looking, this will still ensure everything gets connected correctly
else
    echo "0" >"$STATUSFILE"
fi

# now that the status has been updated, update the monitors
/usr/local/bin/zenbook-scripts/update-screens.sh &