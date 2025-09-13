# this script is called by a hyprland binding, SUPER O in my case
# it just toggles the bottom monitor

STATUSFILE="/tmp/zenbook/zenbook-keyboard-status"

# read current state
if [ -f "$STATUSFILE" ]; then
    STATE=$(cat "$STATUSFILE")
else
    STATE="0"
fi

# toggle state
if [ "$STATE" == "1" ]; then
    hyprctl keyword monitor "eDP-2, preferred, 0x1200, 1.0"
    echo "0" > "$STATUSFILE"
else
    hyprctl keyword monitor "eDP-2, disable"
    echo "1" > "$STATUSFILE"
fi