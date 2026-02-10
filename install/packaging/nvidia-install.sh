# Install NVIDIA packages
mapfile -t packages < <(grep -v '^#' "$KOJARCHY_INSTALL/kojarchy-nvidia.packages" | grep -v '^$')
yay -S --noconfirm --needed "${packages[@]}"
