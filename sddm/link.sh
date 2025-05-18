#!/bin/bash

sudo mkdir -p /usr/share/sddm/themes/catpuccin-mocha
sudo mkdir -p /usr/share/sddm/themes/macos
sudo cp -r sddm/etc/sddm.conf /etc/sddm.conf
sudo cp -r sddm/catpuccin-mocha/* /usr/share/sddm/themes/catpuccin-mocha
sudo cp -r sddm/macos/* /usr/share/sddm/themes/macos
