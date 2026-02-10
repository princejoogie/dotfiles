# Configure Docker daemon
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
    "log-driver": "json-file",
    "log-opts": { "max-size": "10m", "max-file": "5" }
}
EOF

# Start Docker automatically
sudo systemctl enable docker

# Give this user privileged Docker access
sudo usermod -aG docker ${USER}

echo "Docker: OK"
