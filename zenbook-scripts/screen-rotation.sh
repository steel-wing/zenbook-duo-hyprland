#!/bin/bash

STATUSFILE="/tmp/zenbook/zenbook-keyboard-status"

monitor-sensor | while read -r line; do
    case "$line" in
        *normal*)
            hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 0"
            hyprctl keyword monitor "eDP-2, preferred, 0x1200, 1, transform, 0"
            ;;
        *left-up*)
            hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 1"
            hyprctl keyword monitor "eDP-2, preferred, -1200x0, 1, transform, 1"
            ;;
        *right-up*)
            hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 3"
            hyprctl keyword monitor "eDP-2, preferred, 1200x0, 1, transform, 3"
            ;;
    esac

    # end script when keyboard is reattached
    if [[ "$(cat "$STATUSFILE" 2>/dev/null)" == "1" ]]; then
        pkill -P $$ monitor-sensor 
        break
    fi

done