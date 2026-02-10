# Increase PAM faillock limit to 10 attempts with 2min unlock timeout
# This prevents permanent lockout from typos while still protecting against brute force

FAILLOCK_CONF="/etc/security/faillock.conf"

if [[ -f "$FAILLOCK_CONF" ]]; then
  sudo sed -i 's/^#\?\s*deny\s*=.*/deny = 10/' "$FAILLOCK_CONF"
  sudo sed -i 's/^#\?\s*unlock_time\s*=.*/unlock_time = 120/' "$FAILLOCK_CONF"
fi

echo "PAM lockout limit: OK"
