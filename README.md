# zenbook-duo-hyprland
These are the scripts I use on my Arch+Hyprland Asus Zenbook Duo (2024). I leave it to people smarter than I am to adapt them to their own usages. 

Disclaimer: I am new to linux and these might not be optimal.

## Installation
After downloading (and assuming Hyprland is installed) move zenbook.conf, zenbook-keyboard-status and zenbook-scripts into your .config/hypr/ folder, and add this line to your hyprland.conf file: 
```
source = ~/.config/hypr/zenbook.conf
```
Note, you will need to change the value for **TARGET_ID** in screen-wake-response.sh to the id of your own keyboard, which can be found by running
```
lsusb
```
in the terminal, and then finding the ID corresponding to
```
ASUSTek Computer, Inc. ASUS Zenbook Duo Keyboard
```
This will replace the value for **TARGET_ID** that I have, which is 0b05:1b2c.


Then run
```
sudo chmod -R +x ~/.config/hypr/zenbook-scripts
```
to allow all of the scripts to run.
Then, you'll need to add 












Here are some alternative script setups for use on other DEs:
- https://github.com/ywzjackal/zenbook-duo-2025-linux
- https://github.com/alesya-h/zenbook-duo-2024-ux8406ma-linux/
- I know there's one more but it's hard to find
