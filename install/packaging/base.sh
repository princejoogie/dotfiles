# Install all base packages (pacman + AUR via yay)
mapfile -t packages < <(grep -v '^#' "$KOJARCHY_INSTALL/kojarchy-base.packages" | grep -v '^$')
yay -S --noconfirm --needed "${packages[@]}"
