#!/bin/bash

pkill picom

sleep 0.2

picom --config "$HOME"/.config/picom/picom.conf &
