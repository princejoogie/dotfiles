# Prompt user for optional packages
if gum confirm "Install optional packages? (gaming, comms, productivity, etc.)" </dev/tty; then
  mapfile -t packages < <(grep -v '^#' "$KOJARCHY_INSTALL/kojarchy-optional.packages" | grep -v '^$')
  yay -S --noconfirm --needed "${packages[@]}"
fi
