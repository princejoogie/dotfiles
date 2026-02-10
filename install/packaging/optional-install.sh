# Install optional packages (called from optional.sh after user confirms)
mapfile -t packages < <(grep -v '^#' "$KOJARCHY_INSTALL/kojarchy-optional.packages" | grep -v '^$')
yay -S --noconfirm --needed "${packages[@]}"
