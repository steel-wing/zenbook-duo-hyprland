#!/bin/bash

# this script gets called on startup, and ensures that we don't over-charge the battery beyond the specified value

BATTERYFILE="/sys/class/power_supply/BAT0/charge_control_end_threshold"

echo 80 > "$BATTERYFILE"
