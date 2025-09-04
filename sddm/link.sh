#!/bin/bash

sudo mkdir -p /usr/share/sddm/themes/macos
sudo cp -r sddm/macos/* /usr/share/sddm/themes/macos
sudo cp sddm/etc/sddm.conf /etc/sddm.conf
