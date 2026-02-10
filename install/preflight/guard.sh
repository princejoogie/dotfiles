abort() {
  echo -e "\e[31mKojarchy install requires: $1\e[0m"
  echo
  gum confirm "Proceed anyway?" || exit 1
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
if ! ping -c 1 -W 3 1.1.1.1 &>/dev/null; then
  abort "Internet connection"
fi

echo "Guards: OK"
