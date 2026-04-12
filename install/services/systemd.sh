# Enable system services
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now docker.service
sudo systemctl enable --now tailscaled.service

# Enable user services
systemctl --user enable --now pipewire.service
systemctl --user enable --now pipewire-pulse.service
systemctl --user enable --now wireplumber.service

# Note: bluetooth is enabled by config/hardware/bluetooth.sh
# Note: firewall (ufw) is configured by config/firewall.sh

echo "Systemd services: OK"
