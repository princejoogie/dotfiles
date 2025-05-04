#!/bin/bash

spotify_ws=$(hyprctl clients -j | jq -r '.[] | select(.class=="Spotify") | .workspace.id' | head -n1)
[ -n "$spotify_ws" ] && hyprctl dispatch workspace "$spotify_ws"
