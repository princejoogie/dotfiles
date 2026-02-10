# Set GTK dark theme and icon theme via gsettings
if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme "catppuccin-mocha-blue-standard+default" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme "Adwaita" 2>/dev/null || true
fi

echo "GTK theme: OK"
