# Prompt for git identity if not already set
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

echo "Git: OK"
