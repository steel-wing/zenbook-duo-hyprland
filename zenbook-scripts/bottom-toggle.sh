#!/bin/bash

# this script is called by a hyprland binding, SUPER O in my case
# it just toggles the bottom monitor

# if second monitor is live, disable it
if hyprctl monitors | grep -q 'eDP-2'; then
    hyprctl keyword monitor "eDP-2, disable"
else
    # refresh screens to get things the way they should
    /usr/local/bin/zenbook-scripts/update-screens.sh &
fi