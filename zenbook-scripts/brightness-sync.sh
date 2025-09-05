#!/bin/bash

# this script uses brightnessctl to synchronize the brightnessesof the two displays

# paths to brightness files. use brightnessctl 
intel_brightness_file="/sys/class/backlight/intel_backlight/brightness"
card1_brightness_file="/sys/class/backlight/card1-eDP-2-backlight/brightness"

# paths to max_brightness files
intel_max_brightness_file="/sys/class/backlight/intel_backlight/max_brightness"
card1_max_brightness_file="/sys/class/backlight/card1-eDP-2-backlight/max_brightness"

# function to get the current brightness value as a percentage
get_brightness_percentage() {
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

# Inotify wait on the intel_backlight brightness file
inotifywait -m -e modify "$intel_brightness_file" |
while read -r path action file; do
    # get current brightness of intel_backlight (in percentage)
    new_brightness=$(get_brightness_percentage "$intel_brightness_file" "$intel_max_brightness_file")
    
    # set the same brightness for card1-eDP-2-backlight
    brightnessctl --device="card1-eDP-2-backlight" set "${new_brightness}%"
done
