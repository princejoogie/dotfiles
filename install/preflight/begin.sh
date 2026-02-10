clear_logo
gum style --foreground 3 --padding "1 0 0 $PADDING_LEFT" "Installing..."
echo

# Ensure sudo is cached before starting the log (needs tty for password prompt)
sudo -v </dev/tty

# Grant NOPASSWD for the duration of the install so sudo doesn't expire
# in run_logged subshells (stdin is /dev/null, can't prompt for password).
# Cleaned up in post-install/finished.sh.
sudo tee /etc/sudoers.d/99-kojarchy-installer >/dev/null <<EOF
$USER ALL=(ALL) NOPASSWD: ALL
EOF
sudo chmod 440 /etc/sudoers.d/99-kojarchy-installer

start_install_log
