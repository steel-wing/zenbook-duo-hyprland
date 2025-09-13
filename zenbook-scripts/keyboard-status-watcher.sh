#!/bin/bash

# this script is called on boot by hyrland
# it waits until hyprctl is available, then sets up a watcher for zenbook-keyboard-status and updates the bottom monitor accordingly

STATUSFILE="/tmp/zenbook/zenbook-keyboard-status"


# build the directory
mkdir -p "$(dirname "$STATUSFILE")"
touch "$STATUSFILE"

# wait for Hyprland to be ready
while [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; do
    sleep 0.01
done

# export the var so hyprctl can use it
export HYPRLAND_INSTANCE_SIGNATURE

# record previous status
LAST_STATUS=""

# watch for changes
inotifywait -m -e modify "$STATUSFILE" | while read -r _; do
    read -r STATUS < "$STATUSFILE"

    # skip if status is empty or unchanged
    [[ -z "$STATUS" || "$STATUS" == "$LAST_STATUS" ]] && continue

    case "$STATUS" in
        1)
            /usr/bin/hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 0"
            /usr/bin/hyprctl keyword monitor "eDP-2, disable"
            ;;
        0)
            /usr/bin/hyprctl keyword monitor "eDP-2, preferred, 0x1200, 1.0"
            /usr/local/bin/zenbook-scripts/screen-rotation.sh &
            ;;
    esac

    LAST_STATUS="$STATUS"
    
done
