# Copy udev rules and reload
if [[ -d "$KOJARCHY_DIR/system/udev" ]]; then
  sudo cp "$KOJARCHY_DIR"/system/udev/*.rules /etc/udev/rules.d/ 2>/dev/null || true
  sudo udevadm control --reload-rules
  sudo udevadm trigger
fi

echo "Udev: OK"
