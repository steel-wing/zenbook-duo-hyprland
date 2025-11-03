#!/bin/bash

# this script uses brightnessctl to synchronize the brightnesses of the two displays
# only the top screen is directly shown to the OS (11-2025), so this matches bottom to top (and not vice versa)

KEYBOARDFILE="/tmp/zenbook/keyboard-status"
intel_brightness_file="/sys/class/backlight/intel_backlight/brightness"
card1_brightness_file="/sys/class/backlight/card1-eDP-2-backlight/brightness"
intel_max_brightness_file="/sys/class/backlight/intel_backlight/max_brightness"
card1_max_brightness_file="/sys/class/backlight/card1-eDP-2-backlight/max_brightness"

if [[ "$(cat "$KEYBOARDFILE" 2>/dev/null)" == "1" ]]; then
    exit 0
fi

get_top_brightness() {
    local brightness_file=$1
    local max_brightness_file=$2

    # read the current brightness and max brightness values
    local current_brightness
    local max_brightness

    current_brightness=$(cat "$brightness_file")
    max_brightness=$(cat "$max_brightness_file")

    # calculate the percentage of the current brightness
    echo $((100 * current_brightness / max_brightness))
}

set_bottom_brightness() {
    local brightness_file=$1
    local max_brightness_file=$2

    new_brightness=$(get_top_brightness "$intel_brightness_file" "$intel_max_brightness_file")
    brightnessctl --device="card1-eDP-2-backlight" set "${new_brightness}%"
}

# do once before check
set_bottom_brightness "$intel_brightness_file" "$intel_max_brightness_file"

# inotifywait on the intel_backlight brightness file
inotifywait -m -e modify "$intel_brightness_file" |
while read -r path action file; do
    set_bottom_brightness "$intel_brightness_file" "$intel_max_brightness_file"
done
