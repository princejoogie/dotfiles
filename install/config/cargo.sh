source "$KOJARCHY_DIR/lib/packages.sh"

# Ensure rust toolchain is set up
if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

rustup default stable

# Install cargo packages
install_cargo_packages "$KOJARCHY_INSTALL/kojarchy-cargo.packages"

echo "Cargo: OK"
