# Copy over Kojarchy configs to ~/.config/
mkdir -p ~/.config
cp -R "$KOJARCHY_DIR/config/"* ~/.config/

# Use default zshrc from Kojarchy
cp "$KOJARCHY_DIR/default/zshrc" ~/.zshrc

echo "Configs deployed to ~/.config/"
