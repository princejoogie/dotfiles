#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

echo "---" | tee -a /tmp/polybar1-joogie.log

MONITOR=$(xrandr --query | grep "primary" | cut -d" " -f1)
polybar --reload joogie &

# polybar joogie 2>&1 | tee -a /tmp/polybar-joogie.log & disown

echo "Bars launched..."
