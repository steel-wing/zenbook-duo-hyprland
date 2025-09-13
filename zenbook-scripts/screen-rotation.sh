#!/bin/bash

STATUSFILE="/tmp/zenbook/zenbook-keyboard-status"
LAST_STATUS=""

monitor-sensor | while read -r line; do
    # filter for only new orientation information (as opposed to light and tilt)
    if [[ "$line" == *orientation* ]] && [[ "$line" != "$LAST_STATUS" ]]; then
        # tricky fix for after un-mirroring the bottom display
        if [[ "$LAST_STATUS" == *bottom-up* ]]; then
            hyprctl keyword monitor "eDP-2, disable"
        fi

        case "$line" in
            *normal*)
                hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 0"
                hyprctl keyword monitor "eDP-2, preferred, 0x1200, 1, transform, 0"
                LAST_STATUS="$line"
                ;;
            *left-up*)
                hyprctl keyword monitor "eDP-1, preferred, 1200x0, 1, transform, 1"
                hyprctl keyword monitor "eDP-2, preferred, 0x0, 1, transform, 1"
                LAST_STATUS="$line"
                ;;
            *right-up*)
                hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 3"
                hyprctl keyword monitor "eDP-2, preferred, 1200x0, 1, transform, 3"
                LAST_STATUS="$line"
                ;;
            *bottom-up*)
                hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 2"
                hyprctl keyword monitor "eDP-2, preferred, 0x0, 1, transform, 0, mirror, eDP-1"
                LAST_STATUS="$line"
                ;;
        esac
    fi

    # end script when keyboard is reattached
    if [[ "$(cat "$STATUSFILE" 2>/dev/null)" == "1" ]]; then
        pkill -f monitor-sensor
        break
    fi

done