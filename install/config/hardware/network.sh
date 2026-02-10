# Ensure iwd service will be started
sudo systemctl enable iwd.service 2>/dev/null || true

# Prevent systemd-networkd-wait-online timeout on boot
sudo systemctl disable systemd-networkd-wait-online.service 2>/dev/null || true
sudo systemctl mask systemd-networkd-wait-online.service 2>/dev/null || true

echo "Network config: OK"
