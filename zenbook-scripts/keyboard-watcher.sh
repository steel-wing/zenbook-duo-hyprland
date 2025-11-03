#!/bin/bash

# this script is called on boot by hyrland
# it waits until hyprctl is available, then sets up a watcher for keyboard-status and updates the bottom monitor accordingly

KEYBOARDFILE="/tmp/zenbook/keyboard-status"
ORIENTFILE="/tmp/zenbook/orientation-status"

mkdir -p "$(dirname "$KEYBOARDFILE")"
touch "$KEYBOARDFILE"

mkdir -p "$(dirname "$ORIENTFILE")"
touch "$ORIENTFILE"

# wait for Hyprland to be ready
while [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; do
    sleep 0.01
done

export HYPRLAND_INSTANCE_SIGNATURE
LAST_STATUS=""

inotifywait -m -e modify "$KEYBOARDFILE" | while read -r _; do
    read -r STATUS < "$KEYBOARDFILE"

    # skip if status is empty or unchanged
    [[ -z "$STATUS" || "$STATUS" == "$LAST_STATUS" ]] && continue

    if [[ "$(cat "$KEYBOARDFILE" 2>/dev/null)" == "0" ]]; then
        /usr/local/bin/zenbook-scripts/orientation-watcher.sh &
        /usr/local/bin/zenbook-scripts/brightness-sync.sh &
    fi

    /usr/local/bin/zenbook-scripts/update-screens.sh &
    LAST_STATUS="$STATUS"

done
