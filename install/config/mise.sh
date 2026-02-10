# Set up mise global tools (replaces fnm)
if command -v mise &>/dev/null; then
  mise use -g node@latest
fi

echo "Mise: OK"
