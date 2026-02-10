# Installation complete!
stop_install_log

clear_logo

# Calculate elapsed time
if [ -n "${KOJARCHY_START_TIME:-}" ]; then
  KOJARCHY_END_EPOCH=$(date +%s)
  KOJARCHY_START_EPOCH=$(date -d "$KOJARCHY_START_TIME" +%s)
  KOJARCHY_DURATION=$((KOJARCHY_END_EPOCH - KOJARCHY_START_EPOCH))
  KOJARCHY_MINS=$((KOJARCHY_DURATION / 60))
  KOJARCHY_SECS=$((KOJARCHY_DURATION % 60))

  gum style --foreground 2 --padding "1 0 0 $PADDING_LEFT" "Kojarchy installed successfully in ${KOJARCHY_MINS}m ${KOJARCHY_SECS}s!"
else
  gum style --foreground 2 --padding "1 0 0 $PADDING_LEFT" "Kojarchy installed successfully!"
fi

echo
gum style --padding "0 0 0 $PADDING_LEFT" "Reboot to start using your new desktop."
echo

if gum confirm --default --affirmative "Reboot now" --negative "Later" </dev/tty; then
  echo "Rebooting system..." >>"$KOJARCHY_LOG"
  sudo reboot
fi
