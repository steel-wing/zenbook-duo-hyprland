#!/bin/bash

# this script is in charge of lighting up, turning off, or rotating screens based on context.
# it also handles the keyboard backlight function calls

## Load in Contextual Data
KEYBOARDFILE="/tmp/zenbook/keyboard-status"
ORIENTFILE="/tmp/zenbook/orientation-status"
LIDFILE="/proc/acpi/button/lid/LID/state"
BACKLIGHTFILE="/tmp/zenbook/backlight-status"

ORIENT="0"
LID_STATE=""

# read in file contents
read -r STATUS < "$KEYBOARDFILE"
read -r ORIENTATION < "$ORIENTFILE"

# build the backlight status file if it doesn't exist yet
mkdir -p "$(dirname "$BACKLIGHTFILE")"
touch "$BACKLIGHTFILE"

# read in the keyboard backlight status
read -r KB < "$BACKLIGHTFILE"
if [ -z "$KB" ]; then
  KB=0
  echo "$KB" > "$BACKLIGHTFILE"
fi

# read in the lid status
if [ -f "$LIDFILE" ]; then
    LID_STATE=$(grep -i 'state' "$LIDFILE" | awk '{print $2}')
    echo "$LID_STATE"
fi

## Laptop Lid Handling

if [ "$LID_STATE" == "closed" ]; then
    sleep 0.5 # avoiding more silliness, this time with waybar
    hyprctl keyword monitor "eDP-1, disable"
    hyprctl keyword monitor "eDP-2, disable"

    # tricky solution to the "orientation = bottom-up" bug on closing the lid 
    if [[ "$ORIENTATION" == "2" ]]; then
        echo "0" > "$ORIENTFILE"
    fi

    exit
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
# this works for all but screen mirroring mode, where only the bottom touchscreen will be accurate
hyprctl keyword input:touchdevice:transform "$ORIENT"

# reload the current backlight level
/usr/local/bin/zenbook-scripts/keyboard-backlight.py "$KB" &