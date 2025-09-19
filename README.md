# Zenbook Duo - Hyprland
These are the scripts I use on my Arch + Hyprland Asus Zenbook Duo (2024).


## Installation
### Dependencies
These scripts are built on `hyprland` and its accompanying `hyprctl`, which should already be installed. For dependencies, run:
```
sudo pacman -S inotify-tools usbutils iio-sensor-proxy
```


### Hyprland Config
After downloading, move `zenbook.conf` into `~/.config/hypr/`, 
```
cp ~/Downloads/zenbook.conf ~/.config/hypr
```
and add this line to your `hyprland.conf` file: 
```
source = ~/.config/hypr/zenbook.conf
```
_This is assuming that the files from this repository made it into your Downloads folder as they are listed in this directory._


### Scripts
You must modify the value for **TARGET_ID** in `zenbook-scripts/screen-response.sh` to the ID of your own keyboard, which can be found by running `lsusb` in the terminal
while the keyboard is physically connected and then finding the ID corresponding to `ASUSTek Computer, Inc. ASUS Zenbook Duo Keyboard`. Then replace the ID in the code (`0b05:1b2c`) with your own.

Copy the `zenbook-scripts` folder to `/usr/local/bin/` and allow its contents to be run:
```
sudo mkdir /usr/local/bin/zenbook-scripts
sudo cp ~/Downloads/zenbook-scripts/* /usr/local/bin/zenbook-scripts
sudo chmod -R +x /usr/local/bin/zenbook-scripts
```


### udev Rule
Edit `99-asus-bottom-screen.rules` in the same way as you did `screen-response.sh`, replacing the first four characters of the ID in `ATTRS{idVendor}=="0b05"` and the second four in `ATTRS{idProduct}=="1b2c"`.
Be sure to do this for both lines of code (one for removing the keyboard, one for replacing).

Place `99-asus-bottom-screen.rules` in `/etc/udev/rules.d` and reload the rules:
```
sudo cp ~/Downloads/99-asus-bottom-screen.rules /etc/udev/rules.d
sudo udevadm control --reload-rules
```

### Reboot
Finally, reboot. That should ensure that hyprland (via zenbook.conf) loads our `keyboard-watcher.sh` and our udev rule is run.


## Performance
On my machine, currently, the maximum usage of these scripts (in the form of inotifywait and sensor-monitor calls) is around 23MB (with both screens on). It normally sits around 15Mb (when the keyboard is attached). 

## Additional Repos
### On-Screen Keyboard
I use [wvkbd](https://github.com/jjsullivan5196/wvkbd) as my OSK. You're free to alter the keyboard in `osk-toggle.sh` to your own selection. To install `wvkbd-deskintl`, you'll have to download the repository and build it yourself. The repo has instructions on how to do this.

### Battery Health
I use [asus-battery-health](https://github.com/sakibulalikhan/asus-battery-health) to limit charging to 80%, following Asus' default settings.

### Touchscreen Gestures
Hyprland supports plugins, and the [hyprgrass](https://github.com/horriblename/hyprgrass) plugin lets you perform gestures to run commands. I use it to bring up the keyboard, move between workspaces, and alter volume, brightness, etc.

## Warning
There was an issue with the linux kernel for some time which made it so that removing the keyboard disabled the Wi-Fi adapter. This was patched in 6.11+, but seems to have broken again in 6.16.7.arch1-1.



## Features:
- [X] bottom screen automatic keyboard response
- [X] persistant screen state memory
- [X] bottom screen toggle (SUPER + O)
- [X] brightness sync between screens
- [X] automatic screen rotation
- [x] share mode (flip upside down while keyboard removed)
- [X] hyprland touchscreen mappings
- [X] alternative function key bindings (volume etc.)
- [X] on-screen keyboard (via [wvkbd](https://github.com/jjsullivan5196/wvkbd))
- [ ] keyboard backlight
- [ ] touchpad palm rejection
- [ ] fan control
- [ ] an install/uninstall script, and better consolidation

## Resources & Alternatives
- **GNOME**: https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux/
    - Alesya's approach is the most developed I've found.
- **GNOME**: https://github.com/Fmstrat/zenbook-duo-linux
    - This just copies and consolidates Alesya's GNOME approach
- **GNOME & Hyprland**: https://github.com/evilsquid888/zenbook-duo-2024-ux8406ca-linux
      - This one has worked on adapting Alesya's approach to Hyprland, and shows promise!
- **KDE**: https://github.com/ywzjackal/zenbook-duo-2025-linux
- **Nix & Misc.**: https://docs.google.com/spreadsheets/d/1FyQ1RQ8zcTqokwqjNKyVzNravB_R-KRfJmR6frjeE3c/edit?pli=1&gid=0#gid=0
- **Incredible Kernal Work**: https://github.com/NeroReflex/asusctl/issues/25
- **Keyboard Kernal Fix(?)**: https://gist.github.com/mfenniak/f313f9a94fbcfa8fb52f978f29393ab1
- **Fan Control(?)**: https://github.com/dominiksalvet/asus-fan-control/
  
