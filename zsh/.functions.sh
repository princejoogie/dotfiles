v() {
  fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim
}

gc() {
  git branch | fzf-tmux -p --reverse | xargs git checkout
}

gca() {
  git branch -a | fzf-tmux -p --reverse | awk '{gsub("remotes/origin/", "", $1); print $1}' | xargs git checkout
}

ghpr() {
  _branch=$(git branch -a | fzf-tmux -p --reverse | awk '{gsub("remotes/origin/", "", $1); print $1}')
  echo "gh pr create --base $_branch" | pbcopy > /dev/null
  echo "Command has been copued to clipboard"
}

tmss() {
  if [[ $# -eq 1 ]]; then
      selected=$1
  else
      selected=$(find ~/Documents/codes ~/Documents/fgi ~/dotfiles -mindepth 1 -maxdepth 1 -type d | fzf)
  fi

  if [[ -z $selected ]]; then
      exit 0
  fi

  selected_name=$(basename "$selected" | tr . _)
  tmux_running=$(pgrep tmux)

  if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
      tmux new-session -s $selected_name -c $selected
      exit 0
  fi

  if ! tmux has-session -t=$selected_name 2> /dev/null; then
      tmux new-session -ds $selected_name -c $selected
  fi

  tmux switch-client -t $selected_name
}
