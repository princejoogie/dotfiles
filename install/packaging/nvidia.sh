# Detect NVIDIA GPU and prompt for driver installation
if lspci | grep -qi nvidia; then
  if gum confirm "NVIDIA GPU detected. Install NVIDIA drivers?" </dev/tty >/dev/tty 2>/dev/tty; then
    run_logged $KOJARCHY_INSTALL/packaging/nvidia-install.sh
  fi
fi
