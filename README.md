# Zenbook Duo - Hyprland
These are the scripts I use on my Arch + Hyprland Asus Zenbook Duo (2024). I leave it to people smarter than I am to adapt them to their own usages. I also don't trust myself to make an install script, so everything is going to be manual here.

Disclaimer: I am new to linux and these might not be optimal.

## Installation
### Hyprland Config
After downloading (and assuming Hyprland is installed) move zenbook.conf into your .config/hypr/ folder, and add this line to your hyprland.conf file: 
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
Then, you'll need to add 99-asus-bottom-screen.rules to /etc/udev/rules.d

### Reboot
Finally, reboot. That should ensure that hyprland (via zenbook.conf) loads our keyboard-status-watcher.sh script and our udev rule is run. If it isn't, run:
```
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### All done
You should now be able to remove your keyboard, replace it and have brightness sync across screens.

## Future Features:
- Automatic screen rotation when both screens are active
- Better touch screen support (idk w/ hyprland)
- function keys?

## Alternatives
Here are some alternative script setups for use on other DEs:
- (Gnome) https://github.com/ywzjackal/zenbook-duo-2025-linux
- (KDE) https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux/
