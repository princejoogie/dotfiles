# Install neovim via bob
if command -v bob &>/dev/null; then
  bob use stable
fi

# Run lazy.nvim sync headlessly
if command -v nvim &>/dev/null; then
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
fi

echo "Neovim: OK"
