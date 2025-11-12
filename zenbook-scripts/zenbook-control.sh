#!/bin/bash
# zenbook-control.sh
# Unified controller for ASUS Zenbook Duo (UX8406) under Hyprland
# Consolidates all supporting scripts into one file with internal logging and CLI invocation.


ZENBOOK_TMP="/tmp/zenbook"
BACKLIGHTFILE="$ZENBOOK_TMP/backlight-status"
KEYBOARDFILE="$ZENBOOK_TMP/keyboard-status"
ORIENTFILE="$ZENBOOK_TMP/orientation-status"
LOGFILE="$ZENBOOK_TMP/zenbook-control.log"

mkdir -p "$ZENBOOK_TMP"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $*" >> "$LOGFILE"
}

# BSD 2-Clause License
#
# Copyright (c) 2024, Alesya Huzik
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

keyboard_backlight_py() {
    local level="$1"
    python3 - <<'PY' "$level"
import sys, usb.core, usb.util

VENDOR_ID = 0x0b05
PRODUCT_ID = 0x1b2c
REPORT_ID = 0x5A
WVALUE = 0x035A
WINDEX = 4
WLENGTH = 16

try:
    level = int(sys.argv[1])
    if level < 0 or level > 3:
        raise ValueError
except Exception:
    sys.exit(1)

data = [0]*WLENGTH
data[0] = REPORT_ID
data[1:5] = [0xBA, 0xC5, 0xC4, level]

dev = usb.core.find(idVendor=VENDOR_ID, idProduct=PRODUCT_ID)
if dev is None:
    sys.exit(1)

if dev.is_kernel_driver_active(WINDEX):
    try:
        dev.detach_kernel_driver(WINDEX)
    except usb.core.USBError:
        sys.exit(1)

try:
    bmRequestType = 0x21
    bRequest = 0x09
    ret = dev.ctrl_transfer(bmRequestType, bRequest, WVALUE, WINDEX, data, timeout=1000)
except usb.core.USBError:
    usb.util.release_interface(dev, WINDEX)
    sys.exit(1)

usb.util.release_interface(dev, WINDEX)
try:
    dev.attach_kernel_driver(WINDEX)
except usb.core.USBError:
    pass
sys.exit(0)
PY
}

backlight_handler() {
    log "Running backlight_handler"
    mkdir -p "$(dirname "$BACKLIGHTFILE")"
    touch "$BACKLIGHTFILE"

    read -r KB < "$BACKLIGHTFILE"
    if [ -z "$KB" ]; then
        KB=0
        echo "$KB" > "$BACKLIGHTFILE"
    fi

    keyboard_backlight_py "$KB" &
    log "Keyboard backlight set to $KB"
}

backlight_increment() {
    log "Running backlight_increment"
    read -r KB < "$BACKLIGHTFILE"
    if [ -z "$KB" ]; then
        KB=0
        echo "$KB" > "$BACKLIGHTFILE"
    fi

    case "$KB" in
        0) new=1 ;;
        1) new=2 ;;
        2) new=3 ;;
        3) new=0 ;;
    esac

    echo "$new" > "$BACKLIGHTFILE"
    keyboard_backlight_py "$new" &
    log "Backlight incremented to $new"
}

bottom_toggle() {
    log "Running bottom_toggle"
    if hyprctl monitors | grep -q 'eDP-2'; then
        hyprctl keyword monitor "eDP-2, disable"
        log "Bottom monitor disabled"
    else
        update_screens &
        log "Bottom monitor refreshed via update_screens"
    fi
}

brightness_sync() {
    log "Running brightness_sync"
    local intel_brightness_file="/sys/class/backlight/intel_backlight/brightness"
    local card1_brightness_file="/sys/class/backlight/card1-eDP-2-backlight/brightness"
    local intel_max_brightness_file="/sys/class/backlight/intel_backlight/max_brightness"
    local card1_max_brightness_file="/sys/class/backlight/card1-eDP-2-backlight/max_brightness"

    if [[ "$(cat "$KEYBOARDFILE" 2>/dev/null)" == "1" ]]; then
        log "Keyboard attached — brightness sync skipped"
        exit 0
    fi

    get_top_brightness() {
        local brightness_file=$1
        local max_brightness_file=$2
        local current_brightness=$(cat "$brightness_file")
        local max_brightness=$(cat "$max_brightness_file")
        echo $((100 * current_brightness / max_brightness))
    }

    set_bottom_brightness() {
        new_brightness=$(get_top_brightness "$intel_brightness_file" "$intel_max_brightness_file")
        brightnessctl --device="card1-eDP-2-backlight" set "${new_brightness}%" &
        log "Brightness synced: bottom=${new_brightness}%"
    }

    set_bottom_brightness
    inotifywait -m -e modify "$intel_brightness_file" | while read -r _; do
        set_bottom_brightness
    done
}

keyboard_watcher() {
    log "Running keyboard_watcher"
    mkdir -p "$(dirname "$KEYBOARDFILE")" "$(dirname "$ORIENTFILE")"
    touch "$KEYBOARDFILE" "$ORIENTFILE"

    while [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; do sleep 0.01; done
    export HYPRLAND_INSTANCE_SIGNATURE
    LAST_STATUS=""

    inotifywait -m -e modify "$KEYBOARDFILE" | while read -r _; do
        read -r STATUS < "$KEYBOARDFILE"
        [[ -z "$STATUS" || "$STATUS" == "$LAST_STATUS" ]] && continue

        if [[ "$STATUS" == "0" ]]; then
            orientation_watcher &
            brightness_sync &
        else
            pkill -f wvkbd-zenbook
            pkill -f brightness_sync
            pkill -f orientation_watcher
        fi
        update_screens &
        LAST_STATUS="$STATUS"
        log "Keyboard watcher triggered update (STATUS=$STATUS)"
    done
}

orientation_watcher() {
    log "Running orientation_watcher"
    monitor-sensor | while read -r line; do
        if [[ "$line" == *orientation* ]] && [[ "$line" != "$LAST_STATUS" ]]; then
            if [[ "$LAST_STATUS" == *bottom-up* ]]; then
                hyprctl keyword monitor "eDP-2, disable"
            fi
            case "$line" in
                *normal*) echo "0" > "$ORIENTFILE" ;;
                *left-up*) echo "1" > "$ORIENTFILE" ;;
                *bottom-up*) echo "2" > "$ORIENTFILE" ;;
                *right-up*) echo "3" > "$ORIENTFILE" ;;
            esac
            update_screens &
            LAST_STATUS="$line"
            log "Orientation updated: $line"
        fi
    done
}

osk_toggle() {
    log "Running osk_toggle"
    read -r STATUS < "$KEYBOARDFILE"
    read -r ORIENTATION < "$ORIENTFILE"

    if [[ "$STATUS" == "1" ]]; then
        log "Keyboard attached, skipping OSK toggle"
        exit 0
    fi

    WVKBD_PIDs=$(pgrep -x "wvkbd-zenbook")
    if [ -z "$WVKBD_PIDs" ]; then
        hyprctl dispatch focusmonitor eDP-2
        sleep 0.1
        wvkbd-zenbook -H 400 -L 580 &
        log "wvkbd started"
    else
        for pid in $WVKBD_PIDs; do
            kill -34 $pid
        done
        log "wvkbd toggled visibility"
    fi
}

screen_response() {
    log "Running screen_response"
    local TARGET_ID="0b05:1b2c"
    sleep 0.5
    if lsusb | grep -q "$TARGET_ID"; then
        echo "1" > "$KEYBOARDFILE"
    else
        echo "0" > "$KEYBOARDFILE"
    fi
    update_screens &
    log "Screen response triggered update_screens"
}

update_screens() {
    log "Running update_screens"
    local LIDFILE="/proc/acpi/button/lid/LID/state"
    local ORIENT="0"
    local LID_STATE=""

    read -r STATUS < "$KEYBOARDFILE"
    read -r ORIENTATION < "$ORIENTFILE"

    if [ -f "$LIDFILE" ]; then
        LID_STATE=$(grep -i 'state' "$LIDFILE" | awk '{print $2}')
    fi

    if [ "$LID_STATE" == "closed" ]; then
        sleep 0.5
        hyprctl keyword monitor "eDP-1, disable"
        hyprctl keyword monitor "eDP-2, disable"
        if [[ "$ORIENTATION" == "2" ]]; then
            echo "0" > "$ORIENTFILE"
        fi
        log "Lid closed: all displays disabled"
        return
    fi

    case "$STATUS" in
        1)
            hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 0"
            hyprctl keyword monitor "eDP-2, disable"
            ORIENT="0"
            ;;
        0)
            case "$ORIENTATION" in
                0) hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 0"
                   hyprctl keyword monitor "eDP-2, preferred, 0x1200, 1, transform, 0" ;;
                1) hyprctl keyword monitor "eDP-1, preferred, 1200x0, 1, transform, 1"
                   hyprctl keyword monitor "eDP-2, preferred, 0x0, 1, transform, 1" ;;
                2) hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 2"
                   hyprctl keyword monitor "eDP-2, preferred, 0x0, 1, transform, 0, mirror, eDP-1"
                   ORIENT="0" ;;
                3) hyprctl keyword monitor "eDP-1, preferred, 0x0, 1, transform, 3"
                   hyprctl keyword monitor "eDP-2, preferred, 1200x0, 1, transform, 3" ;;
            esac
            ;;
    esac

    hyprctl keyword input:touchdevice:transform "$ORIENT"
    backlight_handler
    log "Screens updated (STATUS=$STATUS, ORIENT=$ORIENTATION)"
}

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <function>"
    echo "Available commands:"
    declare -F | awk '{print "  " $3}' | grep -vE 'log|keyboard_backlight_py'
    exit 1
fi

cmd="$1"
shift
if declare -F "$cmd" >/dev/null 2>&1; then
    "$cmd" "$@"
else
    echo "Unknown command: $cmd"
    exit 1
fi
