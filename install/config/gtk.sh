# Set GTK dark theme and icon theme via gsettings
if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme "catppuccin-mocha-blue-standard+default" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme "Adwaita" 2>/dev/null || true
fi

# Link GTK4/libadwaita theme (Nautilus, GNOME apps ignore gtk-theme gsetting)
THEME_DIR="/usr/share/themes/catppuccin-mocha-blue-standard+default/gtk-4.0"
if [[ -d "$THEME_DIR" ]]; then
  mkdir -p ~/.config/gtk-4.0
  ln -snf "$THEME_DIR/assets" ~/.config/gtk-4.0/assets
  ln -snf "$THEME_DIR/gtk.css" ~/.config/gtk-4.0/gtk.css
  ln -snf "$THEME_DIR/gtk-dark.css" ~/.config/gtk-4.0/gtk-dark.css
fi

echo "GTK theme: OK"
