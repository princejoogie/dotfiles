#!/bin/bash

class=$1

if [ -z "$class" ]; then
    echo "No class specified"
    exit 1
fi

spotify_ws=$(hyprctl clients -j | jq -r '.[] | select(.class=="'"$class"'") | .workspace.id' | head -n1)

[ -n "$spotify_ws" ] && hyprctl dispatch workspace "$spotify_ws"
