# Zenbook Duo - Hyprland
These are the scripts I use on my Asus Zenbook Duo (2024) running Arch + Hyprland. 
While they started out as an attempt at getting the bottom screen to work, the scope is now aimed at feature parity with the drivers and software that ASUS bundles with this device on Windows.


## Installation
### Dependencies
These scripts are built on `hyprland` and its accompanying `hyprctl`, which should already be installed. For dependencies, run:
```
sudo pacman -S inotify-tools usbutils iio-sensor-proxy
```


### Hyprland Config
After downloading, move `zenbook.conf` and into `~/.config/hypr/`, 
```
cp ~/Downloads/zenbook.conf ~/.config/hypr
```
and add this line to your `hyprland.conf` file: 
```
source = ~/.config/hypr/zenbook.conf
```
_This is assuming that the files from this repository made it into your Downloads folder as they are listed in this directory._

### Scripts
The value for **TARGET_ID** in `zenbook-scripts/screen-response.sh` needs to be modified to the ID of your own keyboard, 
which can be found by running `lsusb` in the terminal while the keyboard is physically connected and then finding the ID corresponding to `ASUSTek Computer, Inc. ASUS Zenbook Duo Keyboard`. 
Then replace the ID in the code (`0b05:1b2c`) with your own.


Copy the `zenbook-scripts` folder to `/usr/local/bin/` and allow its contents to be run:
```
sudo mkdir /usr/local/bin/zenbook-scripts
sudo cp ~/Downloads/zenbook-scripts/* /usr/local/bin/zenbook-scripts
sudo chmod -R +x /usr/local/bin/zenbook-scripts
```

### udev Rule
Edit `99-zenbook-keyboard.rules` in the same way as you did `screen-response.sh`, replacing the first four characters of the ID in `ATTRS{idVendor}=="0b05"` and the second four in `ATTRS{idProduct}=="1b2c"`.
Be sure to do this for both lines of code (one for removing the keyboard, one for replacing).


Place `99-zenbook-keyboard.rules` in `/etc/udev/rules.d` and reload the rules:
```
sudo cp ~/Downloads/99-zenbook-keyboard.rules /etc/udev/rules.d
sudo udevadm control --reload-rules
```

### Reboot
Finally, reboot. That should ensure that hyprland (via zenbook.conf) loads our `keyboard-watcher.sh` and our udev rule is run.


## Memory Performance
These scripts should take up about 10 MB while the keyboard is on, and around 30 MB while the keyboard is off.


## Other Code
### Keyboard Backlight
Among other things, [this repo](https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux/) contains a script called bk.py, which sends usb data over to the keyboard and tells it to light up. 
The script requires `python3` and `pyusb` to be installed. It only works while the keyboard is connected.
I've taken this script and included it, unmodified, in this repo for easiness' sake.
Hypridle can manage turning the keyboard on and off dynamically like so:
```
# keyboard dim after 15 seconds
listener {
    timeout = 15
    on-timeout = /usr/local/bin/zenbook-scripts/keyboard-backlight.py 0
    on-resume = /usr/local/bin/zenbook-scripts/backlight-handler.sh
}
```

### On-Screen Keyboard
I use a slightly modified [wvkbd](https://github.com/jjsullivan5196/wvkbd) as my OSK (see [wvkbd-zenbook](https://github.com/steel-wing/wvkbd-zenbook)). You're free to alter the keyboard in `osk-toggle.sh` to your own selection. 
To install `wvkbd-zenbook`, you'll have to download the repository and build it yourself. 
The repo has instructions on how to do this, as well as some instructions on how to theme it.


### Battery Health
I use [asus-battery-health](https://github.com/sakibulalikhan/asus-battery-health) to limit charging to 80%, following Asus' default settings. 
The script only needs to be run once, and it will limit charging from that point onwards.


### Touchscreen Gestures
Hyprland supports plugins, and the [hyprgrass](https://github.com/horriblename/hyprgrass) plugin lets you perform gestures to run commands. 
I use it to bring up the keyboard, move between workspaces, and alter volume, brightness, etc.


## Features:
- [X] bottom screen automatic keyboard response
- [X] bottom screen toggle (SUPER + O)
- [X] brightness sync between screens
- [X] automatic screen rotation
- [X] share mode (flip upside down while keyboard removed)
- [X] hyprland touchscreen mappings
- [X] multi-monitor window fullscreen (SUPER + F7)
- [X] function key bindings (see `zenbook.conf`)
- [ ] function key bindings on bluetooth (volume controls work but nothing else does)
- [ ] on-screen touchpad
- [ ] touchpad palm rejection
- [ ] fan control
- [ ] an install/uninstall script, and better consolidation

## Features from Other Repos:
- [X] keyboard backlight (via [bk.py](https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux/), F4)
- [X] on-screen keyboard (via [wvkbd-zenbook](https://github.com/steel-wing/wvkbd-zenbook), SUPER + A)
- [X] battery charge limiting (via [asus-battery-health](https://github.com/sakibulalikhan/asus-battery-health))
- [X] screen gestures (via [hyprgrass](https://github.com/horriblename/hyprgrass), see `zenbook.conf`)


## Resources & Alternatives
- **GNOME**: https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux/
    - Alesya's approach is the most developed I've found.
- **GNOME**: https://github.com/Fmstrat/zenbook-duo-linux
    - This is a consolidated, more easily installable version of Alesya's GNOME approach
- **GNOME & Hyprland**: https://github.com/evilsquid888/zenbook-duo-2024-ux8406ca-linux
    - This one has worked on adapting Alesya's approach to Hyprland, and may work just as well as (if not better than) mine.
- **Hyprland**: https://www.saminamanat.com/articles/zenbook-duo-wifi-fix
    - A remarkably thorough set of scripts and edits to make sure this works on Hyprland, which also addresses the wifi issue if you still have it.
- **Arch**: https://github.com/ParticleG/
    - This is a lower-level set of support scripts for Arch
- **KDE**: https://github.com/ywzjackal/zenbook-duo-2025-linuxzenbook-duo-keyboard-service/tree/main
- **Nix & Misc.**: https://docs.google.com/spreadsheets/d/1FyQ1RQ8zcTqokwqjNKyVzNravB_R-KRfJmR6frjeE3c/edit?pli=1&gid=0#gid=0
- **asusctl**: https://github.com/NeroReflex/asusctl/
    - lots of general support for asus laptops, support for this one is ongoing
- **Incredible Kernal Work**: https://github.com/NeroReflex/asusctl/issues/25
- **SOURCE**: https://discourse.nixos.org/t/asus-zenbook-duo-2024-ux8406ma-nixos/39792
    - this discussion has a lot of great conversations and clues about the hardware that might be useful.
