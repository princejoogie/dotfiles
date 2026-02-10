run_logged $KOJARCHY_INSTALL/packaging/aur-helper.sh
run_logged $KOJARCHY_INSTALL/packaging/base.sh

# Interactive prompts must run in the main shell (needs tty for gum)
source $KOJARCHY_INSTALL/packaging/nvidia.sh
source $KOJARCHY_INSTALL/packaging/optional.sh

run_logged $KOJARCHY_INSTALL/packaging/fonts.sh
