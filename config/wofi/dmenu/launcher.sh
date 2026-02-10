#!/bin/bash

# Wofi dmenu launcher — lists all kojarchy commands, with web search fallback.
# Bound to ALT+CTRL+SPACE.

SCRIPTS=$(compgen -c kojarchy- | sort -u)

selected=$(printf "%s\n" "$SCRIPTS" | wofi --dmenu -p "Run command or search web" --matching fuzzy)

# Exit if user presses Escape (no input at all)
[ -z "$selected" ] && exit

if printf "%s\n" "$SCRIPTS" | grep -Fxq "$selected"; then
  exec "$selected"
else
  printf "%s" "$selected" | jq -sRr @uri | xargs -r -I{} xdg-open "https://www.google.com/search?q={}"
fi
