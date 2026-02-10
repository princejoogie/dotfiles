# Set GTK/Qt dark theme via gsettings (like omarchy, no config files)
if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
fi

echo "GTK theme: OK"
