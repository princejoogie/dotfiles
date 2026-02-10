# Configure UFW firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow LocalSend file sharing
sudo ufw allow 53317/tcp comment 'LocalSend'
sudo ufw allow 53317/udp comment 'LocalSend'

# Allow Docker DNS
sudo ufw allow in on docker0 to any port 53 proto udp comment 'Docker DNS'

sudo ufw --force enable
sudo systemctl enable --now ufw.service

echo "Firewall: OK"
