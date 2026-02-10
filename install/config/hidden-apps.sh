# Deploy hidden .desktop files to suppress unwanted app launcher entries
APPS_DIR="$HOME/.local/share/applications"
mkdir -p "$APPS_DIR"

cp "$KOJARCHY_DIR/applications/hidden/"*.desktop "$APPS_DIR/" 2>/dev/null || true
update-desktop-database "$APPS_DIR" 2>/dev/null || true

echo "Hidden desktop entries: OK"
