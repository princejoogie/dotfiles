EXTENSIONS_DIR="$HOME/.local/share/nautilus-python/extensions"

mkdir -p "$EXTENSIONS_DIR"
cp "$KOJARCHY_DIR/default/nautilus-python/extensions/localsend.py" "$EXTENSIONS_DIR/"

echo "Nautilus extensions: OK"
