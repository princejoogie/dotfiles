# Fix SSH connection flakiness by enabling MTU probing
if ! grep -q "tcp_mtu_probing" /etc/sysctl.d/99-sysctl.conf 2>/dev/null; then
  echo "net.ipv4.tcp_mtu_probing=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf
  sudo sysctl -p /etc/sysctl.d/99-sysctl.conf
fi

echo "SSH MTU probing fix: OK"
