clear_logo
gum style --foreground 3 --padding "1 0 0 $PADDING_LEFT" "Installing..."
echo

# Ensure sudo is cached before starting the log (needs tty for password prompt)
sudo -v </dev/tty

start_install_log
