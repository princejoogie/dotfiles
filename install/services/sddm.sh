# Install SDDM with custom macOS theme + autologin

# Copy macOS theme to SDDM themes directory
sudo mkdir -p /usr/share/sddm/themes/macos
sudo cp -R "$KOJARCHY_DIR/sddm/macos/"* /usr/share/sddm/themes/macos/

# Configure SDDM: macOS theme + autologin
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/kojarchy.conf >/dev/null <<EOF
[Theme]
Current=macos

[Autologin]
User=$USER
Session=hyprland
EOF

# Enable SDDM
sudo systemctl enable sddm.service

echo "SDDM: OK"
