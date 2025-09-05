# Zenbook Duo - Hyprland
These are the scripts I use on my Arch + Hyprland Asus Zenbook Duo (2024). These scripts are built on `hyprland` and `hyprctl`, which should already be installed, as well as `inotify-tools` (for `inotifywait`), and `usbutils` (for `lsusb`). To download all these, run:
```
sudo pacman -S hyprland hyprctl inotify-tools usbutils
```

## Installation
### Hyprland Config
After downloading, move `zenbook.conf` into `~/.config/hypr/`, and add this line to your `hyprland.conf` file: 
```
source = ~/.config/hypr/zenbook.conf
```
### Scripts
You must modify the value for **TARGET_ID** in `zenbook-scripts/screen-wake-response.sh` to the ID of your own keyboard, which can be found by running `lsusb` 
while the keyboard is physically connected and finding the ID corresponding to `ASUSTek Computer, Inc. ASUS Zenbook Duo Keyboard` and replacing mine (`0b05:1b2c`) with your own.

Then copy the `zenbook-scripts` folder to `/usr/local/bin/` and allow its contents to be run:
```
sudo mkdir /usr/local/bin/zenbook-scripts
sudo mv ~/Downloads/zenbook-duo-hyprland-main/zenbook-scripts/* /usr/local/bin/zenbook-scripts
sudo chmod -R +x /usr/local/bin/zenbook-scripts
```
_This is assuming that the files from this repository made it into your Downloads folder in a folder named `zenbook-duo-hyprland-main`_

### Udev Rule
Edit `99-asus-bottom-screen.rules` in the same way as you did `screen-wake-response.sh`, replacing the first four characters of the ID as in `ATTRS{idVendor}=="0b05"` and the second four as in `ATTRS{idProduct}=="1b2c"`.
Be sure to do this for both lines of code (one for removing the keyboard, one for replacing).

Place `99-asus-bottom-screen.rules` in `/etc/udev/rules.d` and reload the rules:
```
sudo mv ~/Downloads/zenbook-duo-hyprland-main/99-asus-bottom-screen.rules /etc/udev/rules.d
sudo udevadm control --reload-rules
```

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
- **KDE**: https://github.com/ywzjackal/zenbook-duo-2025-linux
- **GNOME**: https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux/
- **Ubuntu**: https://github.com/Fmstrat/zenbook-duo-linux
    - Ubuntu based; this copies and consolidates Alesya's GNOME approach
- **Nix & Misc.**: https://docs.google.com/spreadsheets/d/1FyQ1RQ8zcTqokwqjNKyVzNravB_R-KRfJmR6frjeE3c/edit?pli=1&gid=0#gid=0
- **Battery Health**: https://github.com/sakibulalikhan/asus-battery-health
  
