#!/bin/bash

# this script is called on boot by hyrland
# it waits until hyprctl is available, then sets up a watcher for keyboard-status and updates the bottom monitor accordingly

STATUSFILE="/tmp/zenbook/keyboard-status"
ORIENTFILE="/tmp/zenbook/orientation-status"

# build the keyboard status file
mkdir -p "$(dirname "$STATUSFILE")"
touch "$STATUSFILE"

# build the laptop orientation file
mkdir -p "$(dirname "$ORIENTFILE")"
touch "$ORIENTFILE"
echo "0" > "$ORIENTFILE"

# wait for Hyprland to be ready
while [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; do
    sleep 0.01
done

# export the var so hyprctl can use it
export HYPRLAND_INSTANCE_SIGNATURE

# record previous status (this is necessary to avoid repeat calls)
LAST_STATUS=""

# watch for changes
inotifywait -m -e modify "$STATUSFILE" | while read -r _; do
    read -r STATUS < "$STATUSFILE"

    # skip if status is empty or unchanged
    [[ -z "$STATUS" || "$STATUS" == "$LAST_STATUS" ]] && continue

    # if the bottom screen isn't attached, start up the rotation detection script
    if [[ "$(cat "$STATUSFILE" 2>/dev/null)" == "0" ]]; then
        /usr/local/bin/zenbook-scripts/orientation-watcher.sh &
    fi

    # now that status and orientation are defined, now we can update the screens
    /usr/local/bin/zenbook-scripts/update-screens.sh &
    LAST_STATUS="$STATUS"

done
