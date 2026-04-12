# Increase sudo password attempts from default 3 to 10
SUDOERS_FILE="/etc/sudoers.d/99-kojarchy-passwd-tries"
if [[ ! -f "$SUDOERS_FILE" ]]; then
  echo 'Defaults passwd_tries=10' | sudo tee "$SUDOERS_FILE"
  sudo chmod 440 "$SUDOERS_FILE"
fi

echo "Sudo password tries: OK"
