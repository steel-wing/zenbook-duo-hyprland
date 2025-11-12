#!/bin/bash
# zenbook-setup.sh
# Detects the Zenbook Duo keyboard USB ID and updates zenbook-control.sh + config file.

SCRIPT_PATH="/usr/local/bin/zenbook-control"
CONF_FILE="/etc/zenbook-control.conf"
DEFAULT_ID="0b05:1b2c"

echo "Installing zenbook control script"
echo

# move scripts into places, set things up, that kind of thing.





echo "🔍 Detecting ASUS Zenbook Duo Keyboard via lsusb..."
echo

DETECTED_ID=$(lsusb | grep -i "ASUSTek Computer, Inc. ASUS Zenbook Duo Keyboard" | awk '{print $6}')

if [ -z "$DETECTED_ID" ]; then
    echo "⚠️  Could not auto-detect the keyboard."
    echo "Here are all ASUS devices found on your system:"
    lsusb | grep -i asus || echo "  (none)"
    echo
    read -p "Please enter your keyboard's USB ID (format: vendor:product, e.g. 0b05:1b2c): " USER_ID
    DETECTED_ID="$USER_ID"
fi

if [[ ! "$DETECTED_ID" =~ ^[0-9a-fA-F]{4}:[0-9a-fA-F]{4}$ ]]; then
    echo "❌ Invalid USB ID format. Expected something like 0b05:1b2c"
    exit 1
fi

echo "✅ Keyboard detected: $DETECTED_ID"
echo

# Write config file
echo "🛠️  Saving config to $CONF_FILE ..."
sudo mkdir -p "$(dirname "$CONF_FILE")"
echo "TARGET_ID=\"$DETECTED_ID\"" | sudo tee "$CONF_FILE" >/dev/null

# Ensure main script exists
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ zenbook-control script not found at $SCRIPT_PATH"
    echo "If you installed it elsewhere, edit this setup script and update SCRIPT_PATH."
    exit 1
fi

# Patch zenbook-control.sh so it sources the config (if not already present)
if ! grep -q "zenbook-control.conf" "$SCRIPT_PATH"; then
    echo "📦 Patching $SCRIPT_PATH to source config file ..."
    sudo sed -i '/^### GLOBAL CONFIGURATION/a \
if [ -f /etc/zenbook-control.conf ]; then \
    source /etc/zenbook-control.conf \
else \
    TARGET_ID="0b05:1b2c" \
fi' "$SCRIPT_PATH"
fi

# Replace any hardcoded TARGET_ID in the file
sudo sed -i "s/local TARGET_ID=\"[0-9a-fA-F:]*\"/local TARGET_ID=\"$DETECTED_ID\"/" "$SCRIPT_PATH"

echo "✅ zenbook-control updated with USB ID $DETECTED_ID"
echo "⚙️  Configuration saved to $CONF_FILE"
echo
echo "You can rerun this script anytime if your keyboard hardware changes."
echo
echo "Test with:"
echo "  sudo $SCRIPT_PATH screen_response"


# tell user about setting up correct hyprland stuff and such.
