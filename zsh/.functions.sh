v() {
  fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim
}

gc() {
  git branch | fzf-tmux -p --reverse | xargs git checkout
}

gca() {
  git branch -a | fzf-tmux -p --reverse | awk '{gsub("remotes/origin/", "", $1); print $1}' | xargs git checkout
}
