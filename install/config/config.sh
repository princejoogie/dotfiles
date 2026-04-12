# Symlink Kojarchy-managed configs into ~/.config/ so updates apply immediately.
mkdir -p ~/.config

while IFS= read -r -d '' source_path; do
  rel_path="${source_path#$KOJARCHY_DIR/config/}"
  target_path="$HOME/.config/$rel_path"

  mkdir -p "$(dirname "$target_path")"

  if [[ -L "$target_path" ]]; then
    if [[ "$(readlink "$target_path")" == "$source_path" ]]; then
      continue
    fi
    rm -f "$target_path"
  elif [[ -e "$target_path" ]]; then
    mv "$target_path" "${target_path}.bak.$(date +%Y%m%d%H%M%S)"
  fi

  ln -s "$source_path" "$target_path"
done < <(find "$KOJARCHY_DIR/config" \( -type f -o -type l \) -print0)

# Use default zshrc from Kojarchy
cp "$KOJARCHY_DIR/default/zshrc" ~/.zshrc

echo "Configs symlinked into ~/.config/"
