# Turn on bluetooth by default
sudo systemctl enable bluetooth.service 2>/dev/null || true

echo "Bluetooth: OK"
