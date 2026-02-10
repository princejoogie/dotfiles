run_logged $KOJARCHY_INSTALL/packaging/aur-helper.sh
run_logged $KOJARCHY_INSTALL/packaging/base.sh

# Pause log tail for interactive prompts (it overwrites the screen)
stop_log_output
clear_logo
source $KOJARCHY_INSTALL/packaging/nvidia.sh
source $KOJARCHY_INSTALL/packaging/optional.sh
clear_logo
start_log_output

run_logged $KOJARCHY_INSTALL/packaging/fonts.sh
