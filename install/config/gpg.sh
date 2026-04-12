# Deploy GPG keyserver configuration with multiple fallbacks
mkdir -p "$HOME/.gnupg"
cp "$KOJARCHY_DIR/default/gpg/dirmngr.conf" "$HOME/.gnupg/dirmngr.conf"
chmod 700 "$HOME/.gnupg"
chmod 600 "$HOME/.gnupg/dirmngr.conf"

echo "GPG keyserver config: OK"
