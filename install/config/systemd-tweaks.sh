# Apply systemd tweaks (faster shutdown timeout)
sudo mkdir -p /etc/systemd/system.conf.d
sudo cp "$KOJARCHY_DIR/default/systemd/faster-shutdown.conf" /etc/systemd/system.conf.d/faster-shutdown.conf

echo "Systemd tweaks: OK"
