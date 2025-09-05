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

# execute the wake response script first to get things right
/usr/local/bin/zenbook-scripts/screen-wake-response.sh

# watch for changes
inotifywait -m -e create,close_write "$STATUSFILE" | while read -r filename event; do
    # wait in case this is a creation and not just an update
    sleep 0.01

    STATUS=$(cat "$STATUSFILE" 2>/dev/null)
    case "$STATUS" in
        on)
            /usr/bin/hyprctl keyword monitor "eDP-2, disable"
            ;;
        of)
            /usr/bin/hyprctl keyword monitor "eDP-2, preferred, 0x1200, 1.0"
            ;;
    esac
done
