#!/bin/bash

# this script toggles the visibility of wvkbd
# credit to a deleted user on reddit from 2 years ago for this one

# Save the current IFS
OLD_IFS=$IFS

# Set IFS to newline
IFS=$'\n'

# Get the PIDs of wvkbd
WVKBD_PIDs=$(pgrep -x "wvkbd-mobintl")

# Check if wvkbd is running
if [ -z "$WVKBD_PIDs" ]; then

    # wvkbd is not running, so start it
    wvkbd-mobintl -H 450 -L 450 &

else
    # wvkbd is running, so toggle its visibility for each PID
    for pid in $WVKBD_PIDs; do
        kill -34 $pid
    done
fi

# Restore the original IFS
IFS=$OLD_IFS