#!/bin/bash

# this script is in charge of keeping track of the orientation of the laptop, if 

STATUSFILE="/tmp/zenbook/keyboard-status"
ORIENTFILE="/tmp/zenbook/orientation-status"

monitor-sensor | while read -r line; do

    # filter for only new orientation information (as opposed to light and tilt)
    if [[ "$line" == *orientation* ]] && [[ "$line" != "$LAST_STATUS" ]]; then

        # tricky fix for after un-mirroring the bottom display
        if [[ "$LAST_STATUS" == *bottom-up* ]]; then
            hyprctl keyword monitor "eDP-2, disable"
        fi

        case "$line" in
            *normal*)
                echo "0" > "$ORIENTFILE"
                ;;
            *left-up*)
                echo "1" > "$ORIENTFILE"
                ;;
            *right-up*)
                echo "3" > "$ORIENTFILE"
                ;;
            *bottom-up*)
                echo "2" > "$ORIENTFILE"
                ;;
        esac
        
        # when something changes, make sure we update the screens to match
        /usr/local/bin/zenbook-scripts/update-screens.sh &
        LAST_STATUS="$line"

    fi

    # end this script when keyboard is reattached
    if [[ "$(cat "$STATUSFILE" 2>/dev/null)" == "1" ]]; then
        echo "0" > "$ORIENTFILE"
        pkill -f monitor-sensor
        break
    fi

done