abort() {
  echo -e "\e[31mKojarchy install requires: $1\e[0m"
  echo
  if ! gum confirm "Proceed anyway?" </dev/tty; then
    exit 1
  fi
}

# Must be an Arch distro
if [[ ! -f /etc/arch-release ]]; then
  abort "Arch Linux"
fi

# Must not be running as root
if [ "$EUID" -eq 0 ]; then
  abort "Running as non-root user"
fi

# Must have internet
if ! ping -c 1 -W 3 1.1.1.1 &>/dev/null && ! ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
  abort "Internet connection"
fi

# Clear stale pacman lock from previous interrupted runs
if [[ -f /var/lib/pacman/db.lck ]]; then
  sudo rm -f /var/lib/pacman/db.lck
fi

echo "Guards: OK"
