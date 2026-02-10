# Install TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"

if [[ ! -d "$TPM_DIR" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Install tmux plugins
"$TPM_DIR/bin/install_plugins" || true

echo "Tmux: OK"
