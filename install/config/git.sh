# Keep shared git defaults in-repo so they update with git pull.
include_path="$KOJARCHY_DIR/default/gitconfig"

if [[ -f "$include_path" ]] && ! git config --global --get-all include.path 2>/dev/null | grep -Fxq "$include_path"; then
  git config --global --add include.path "$include_path"
fi

# Prompt for git identity if not already set (runs via source, not run_logged)
if [[ -z "$(git config --global user.name)" ]]; then
  name=$(gum input --placeholder "Your full name" --header "Git user.name:" </dev/tty)
  if [[ -n "$name" ]]; then
    git config --global user.name "$name"
  fi
fi

if [[ -z "$(git config --global user.email)" ]]; then
  email=$(gum input --placeholder "you@example.com" --header "Git user.email:" </dev/tty)
  if [[ -n "$email" ]]; then
    git config --global user.email "$email"
  fi
fi

echo "Git: OK" >>"$KOJARCHY_LOG"
