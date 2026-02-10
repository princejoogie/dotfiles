# Install yay if not present
if ! command -v yay &>/dev/null; then
  echo "Installing yay AUR helper..."
  sudo pacman -S --needed --noconfirm git base-devel
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
  cd "$tmpdir/yay-bin"
  makepkg -si --noconfirm
  cd -
  rm -rf "$tmpdir"
fi

echo "yay: OK"
