# Prompt user for optional packages (runs in main shell for tty access)
if gum confirm "Install optional packages? (gaming, comms, productivity, etc.)" </dev/tty >/dev/tty 2>/dev/tty; then
  run_logged $KOJARCHY_INSTALL/packaging/optional-install.sh
fi
