# Enable system services
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now docker.service
sudo systemctl enable --now tailscaled.service

# Enable user services
systemctl --user enable --now pipewire.service
systemctl --user enable --now pipewire-pulse.service
systemctl --user enable --now wireplumber.service

# Firewall
sudo systemctl enable --now ufw.service
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

echo "Systemd services: OK"
