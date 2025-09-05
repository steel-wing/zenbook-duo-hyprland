# Zenbook Duo - Hyprland
These are the scripts I use on my Arch + Hyprland Asus Zenbook Duo (2024). I leave it to people smarter than I am to adapt them to their own usages.

These scripts sync brightness across the screens, enable the bottom screen when the keyboard is removed, and disable it when it's replaced.

Disclaimer: I am new to linux and these might not be optimal.

## Installation
### Hyprland Config
After downloading, move zenbook.conf into ~/.config/hypr/, and add this line to your hyprland.conf file: 
```
source = ~/.config/hypr/zenbook.conf
```
### Scripts
Copy the zenbook-scripts folder to /usr/local/bin/ and run:
```
sudo chmod -R +x /usr/local/bin/zenbook-scripts
```

Note, you will need to change the value for **TARGET_ID** in zenbook-scripts/screen-wake-response.sh to the ID of your own keyboard, which can be found by running
```
lsusb
```
in the terminal, and then finding the ID corresponding to
```
ASUSTek Computer, Inc. ASUS Zenbook Duo Keyboard
```
then just replace mine (0b05:1b2c) with your own.


### Udev Rule
Place 99-asus-bottom-screen.rules to /etc/udev/rules.d and run
```
sudo udevadm control --reload-rules
```
to ensure that the rule is loaded.

### Reboot
Finally, reboot. That should ensure that hyprland (via zenbook.conf) loads our keyboard-status-watcher.sh and our udev rule is run.


## Future Features:
- Automatic screen rotation when both screens are active
- Better touch screen support
- function keys & keyboard bindings
- keyboard backlight
- the engimatic bottom screen disable button
- an install/deinstall script, and better consolidation

## Alternatives
Here are some alternative script setups for use on other DEs:
- (KDE) https://github.com/ywzjackal/zenbook-duo-2025-linux
- (GNOME) https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux/
