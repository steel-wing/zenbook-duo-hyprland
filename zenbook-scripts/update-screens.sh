#!/bin/bash

# this script is in charge of lighting up, turning off, or rotating screens based on context.

## Load in Contextual Data

STATUSFILE="/tmp/zenbook/keyboard-status"
ORIENTFILE="/tmp/zenbook/orientation-status"
LIDFILE="/proc/acpi/button/lid/LID/state"

ORIENT=""
LID_STATE=""

# read in file contents
read -r STATUS < "$STATUSFILE"
read -r ORIENTATION < "$ORIENTFILE"
if [ -f "$LIDFILE" ]; then
    LID_STATE=$(grep -i 'state' "$LIDFILE" | awk '{print $2}')
fi

## Laptop Lid Handling

if [ "$LID_STATE" == "closed" ]; then
    sleep 0.5 # avoiding more silliness, this time with waybar
    hyprctl keyword monitor "eDP-1, disable"
    hyprctl keyword monitor "eDP-2, disable"
fi

## Keyboard & Orientation Handling

case "$STATUS" in
1)
        # handle the standard laptop situation
        hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 0"
        hyprctl keyword monitor "eDP-2, disable"
        ORIENT="0"
        ;;
0)
        # handle responding to different orientations
        case "$ORIENTATION" in
        0)  
                hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 0"
                hyprctl keyword monitor "eDP-2, preferred, 0x1200, 1, transform, 0"
                ORIENT="0"
                ;;
        1)
                hyprctl keyword monitor "eDP-1, preferred, 1200x0, 1, transform, 1"
                hyprctl keyword monitor "eDP-2, preferred, 0x0, 1, transform, 1"
                ORIENT="1"
                ;;
        2)
                # flip laptop over momentarily to activate ASUS's little "screen mirror mode"
                hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 2"
                hyprctl keyword monitor "eDP-2, preferred, 0x0, 1, transform, 0, mirror, eDP-1"
                ORIENT="0"
                ;;
        3)
                hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 3"
                hyprctl keyword monitor "eDP-2, preferred, 1200x0, 1, transform, 3"
                ORIENT="3"
                ;;
        esac
        ;;
esac

# update orientation of touch & stylus input
# this works for all but screen mirroring mode, where only the bottom will be accurate
hyprctl keyword input:touchdevice:transform "$ORIENT"