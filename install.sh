#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define Kojarchy locations
export KOJARCHY_DIR="$HOME/dotfiles"
export KOJARCHY_INSTALL="$KOJARCHY_DIR/install"
export KOJARCHY_LOG="/var/log/kojarchy-install.log"
export PATH="$KOJARCHY_DIR/bin:$PATH"

# Install
source "$KOJARCHY_DIR/lib/helpers.sh"
source "$KOJARCHY_INSTALL/preflight/all.sh"
source "$KOJARCHY_INSTALL/packaging/all.sh"
source "$KOJARCHY_INSTALL/config/all.sh"
source "$KOJARCHY_INSTALL/services/all.sh"
source "$KOJARCHY_INSTALL/post-install/all.sh"
