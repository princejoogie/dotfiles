# Initialize persistent toggle directories used by Kojarchy.

TOGGLE_DIR="$HOME/.local/state/kojarchy/toggles/hypr"
mkdir -p "$TOGGLE_DIR"
cp "$KOJARCHY_DIR/default/hypr/toggles/flags.conf" "$TOGGLE_DIR/flags.conf"
