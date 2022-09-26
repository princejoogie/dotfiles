#!/bin/sh
xrandr --auto
xrandr --output DP-0 --primary --mode 3440x1440 --pos 0x240 --rotate normal --rate 144.00
xrandr --output HDMI-0 --mode 1920x1080 --pos 3440x0 --rotate right --rate 60.00
