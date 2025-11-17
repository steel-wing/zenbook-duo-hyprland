#!/bin/bash

# this script toggles the zenbook fullscreen effect

hyprctl dispatch togglefloating active
hyprctl dispatch moveactive exact 2 20
hyprctl dispatch resizeactive exact 1916 2392
