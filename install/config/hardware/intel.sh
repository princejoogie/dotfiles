# Install hardware video acceleration for Intel GPUs
if INTEL_GPU=$(lspci | grep -iE 'vga|3d|display' | grep -i 'intel'); then
  if [[ "${INTEL_GPU,,}" =~ "hd graphics"|"xe"|"iris" ]]; then
    sudo pacman -S --needed --noconfirm intel-media-driver
  elif [[ "${INTEL_GPU,,}" =~ "gma" ]]; then
    sudo pacman -S --needed --noconfirm libva-intel-driver
  fi
  echo "Intel GPU acceleration: OK"
else
  echo "No Intel GPU detected, skipping"
fi
