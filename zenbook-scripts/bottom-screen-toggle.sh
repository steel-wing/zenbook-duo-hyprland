# this script is called by a hyprland binding, SUPER O in my case
# it just toggles the bottom monitor

STATUSFILE="/tmp/zenbook/zenbook-keyboard-status"

# read current state
if [ -f "$STATUSFILE" ]; then
    STATE=$(cat "$STATUSFILE")
else
    STATE="of"
fi

# toggle state
if [ "$STATE" == "on" ]; then
    hyprctl keyword monitor "eDP-2, preferred, 0x1200, 1.0"
    echo "of" > "$STATUSFILE"
else
    hyprctl keyword monitor "eDP-2, disable"
    echo "on" > "$STATUSFILE"

    # check to see if the top screen should be off too, if the lid is close
    /usr/local/bin/zenbook-scripts/screen-wake-response.sh
fi
