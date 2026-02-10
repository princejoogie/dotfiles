# Temporarily disable mkinitcpio hooks to prevent multiple regenerations during package install
# This speeds up installation significantly — re-enabled in post-install

echo "Temporarily disabling mkinitcpio hooks during installation..."

if [ -f /usr/share/libalpm/hooks/90-mkinitcpio-install.hook ]; then
  sudo mv /usr/share/libalpm/hooks/90-mkinitcpio-install.hook /usr/share/libalpm/hooks/90-mkinitcpio-install.hook.disabled
fi

if [ -f /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook ]; then
  sudo mv /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook.disabled
fi

echo "mkinitcpio hooks disabled: OK"
