# Symlink systemd-resolved stub to /etc/resolv.conf
# This ensures DNS works reliably with NetworkManager + systemd-resolved
sudo systemctl enable --now systemd-resolved.service 2>/dev/null || true

if [[ -L /etc/resolv.conf ]]; then
  echo "DNS resolver: already symlinked"
else
  sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
  echo "DNS resolver: OK"
fi
