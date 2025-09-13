#!/bin/bash

# this script runs during startup and after opening the lid
# it ensures that the bottom monitor reflects the physical status of the keyboard

TARGET_ID=0b05:1b2c # lsusb id of zenbook keyboard
LID_PATH="/proc/acpi/button/lid/LID/state"
STATUSFILE="/tmp/zenbook/zenbook-keyboard-status"

# very silly way of getting around hyprland issues after reload
sleep 0.5

# read current state of the keyboard
if lsusb | grep -q "$TARGET_ID"; then
  hyprctl keyword monitor "eDP-2, disable"
  echo "1" >"$STATUSFILE"
else
  hyprctl keyword monitor "eDP-2, preferred, 0x1200, 1.0"
  echo "0" >"$STATUSFILE"
fi

# if you're using an external monitor with the laptop closed,
# this should ensure the top monitor doesn't stay on

# read the state of the lid
LID_STATE="unknown"
if [ -f "$LID_PATH" ]; then
  LID_STATE=$(grep -i 'state' "$LID_PATH" | awk '{print $2}')
fi

# respond to lid state
if [ "$LID_STATE" == "closed" ]; then
  sleep 0.5 # avoiding more silliness, this time with waybar
  hyprctl keyword monitor "eDP-1, disable"
  hyprctl keyword monitor "eDP-2, disable"
fi