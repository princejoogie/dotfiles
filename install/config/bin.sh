# Symlink bin scripts to ~/.local/custom/bin/
mkdir -p ~/.local/custom/bin

for script in "$KOJARCHY_DIR"/bin/*; do
  local_name="$HOME/.local/custom/bin/$(basename "$script")"
  ln -sf "$script" "$local_name"
done

echo "Bin scripts linked to ~/.local/custom/bin/"
