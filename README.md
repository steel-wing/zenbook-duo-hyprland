# Zenbook Duo - Hyprland
These are the scripts I use on my Arch + Hyprland Asus Zenbook Duo (2024). These scripts require `hyprland`, `hyprctl`, `inotifywait`, and `lsusb` be installed.

## Installation
### Hyprland Config
After downloading, move `zenbook.conf` into `~/.config/hypr/`, and add this line to your `hyprland.conf` file: 
```
source = ~/.config/hypr/zenbook.conf
```
### Scripts
Copy the `zenbook-scripts` folder to `/usr/local/bin/` and run:
```
sudo chmod -R +x /usr/local/bin/zenbook-scripts
```

Note, you will need to change the value for **TARGET_ID** in `zenbook-scripts/screen-wake-response.sh` to the ID of your own keyboard, which can be found by running:
```
lsusb
```
while the keyboard is physically connected and finding the ID corresponding to `ASUSTek Computer, Inc. ASUS Zenbook Duo Keyboard` and replacing mine (`0b05:1b2c`) with your own.


### Udev Rule
Place `99-asus-bottom-screen.rules` in `/etc/udev/rules.d` and run:
```
sudo udevadm control --reload-rules
```
to ensure that the rule is loaded.

### Reboot
Finally, reboot. That should ensure that hyprland (via zenbook.conf) loads our `keyboard-status-watcher.sh` and our udev rule is run.


## Features:
- [X] bottom screen automatic keyboard response
- [X] bottom screen toggle (SUPER + O)
- [X] brightness sync
- [ ] automatic screen rotation when both screens are active
- [ ] better touch screen support on hyprland
- [ ] stylus support
- [ ] alternative function key bindings (volume etc.)
- [ ] keyboard backlight
- [ ] the engimatic bottom screen disable button
- [ ] an install/uninstall script, and better consolidation

## Resources & Alternatives
- **KDE** https://github.com/ywzjackal/zenbook-duo-2025-linux
- **GNOME** https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux/
- **Ubuntu** https://github.com/Fmstrat/zenbook-duo-linux
    - Ubuntu based; this copies and consolidates Alesya's
- **Nix** https://docs.google.com/spreadsheets/d/1FyQ1RQ8zcTqokwqjNKyVzNravB_R-KRfJmR6frjeE3c/edit?pli=1&gid=0#gid=0
- **Battery Health** https://github.com/sakibulalikhan/asus-battery-health
  
