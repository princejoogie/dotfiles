#!/bin/bash

# Kojarchy error handling - traps, recovery menu

# Track if we're already handling an error to prevent double-trapping
ERROR_HANDLING=false

show_cursor() {
  printf "\033[?25h"
}

show_log_tail() {
  if [[ -f $KOJARCHY_LOG ]]; then
    local log_lines=$(($TERM_HEIGHT - $LOGO_HEIGHT - 20))
    local max_line_width=$((LOGO_WIDTH - 4))

    tail -n $log_lines "$KOJARCHY_LOG" | while IFS= read -r line; do
      if ((${#line} > max_line_width)); then
        local truncated_line="${line:0:$max_line_width}..."
      else
        local truncated_line="$line"
      fi
      gum style "$truncated_line"
    done
    echo
  fi
}

show_failed_script_or_command() {
  if [[ -n ${CURRENT_SCRIPT:-} ]]; then
    gum style "Failed script: $CURRENT_SCRIPT"
  else
    local cmd="$BASH_COMMAND"
    local max_cmd_width=$((LOGO_WIDTH - 4))
    if ((${#cmd} > max_cmd_width)); then
      cmd="${cmd:0:$max_cmd_width}..."
    fi
    gum style "$cmd"
  fi
}

# Save original stdout and stderr for trap to use
save_original_outputs() {
  exec 3>&1 4>&2
}

restore_outputs() {
  if [ -e /proc/self/fd/3 ] && [ -e /proc/self/fd/4 ]; then
    exec 1>&3 2>&4
  fi
}

catch_errors() {
  if [[ $ERROR_HANDLING == true ]]; then
    return
  else
    ERROR_HANDLING=true
  fi

  local exit_code=$?

  stop_log_output
  restore_outputs

  clear_logo
  show_cursor

  gum style --foreground 1 --padding "1 0 1 $PADDING_LEFT" "Kojarchy installation stopped!"
  show_log_tail

  gum style "This command halted with exit code $exit_code:"
  show_failed_script_or_command

  echo
  gum style --foreground 245 "If you need help, open an issue at:"
  gum style --foreground 4 "https://github.com/princejoogie/dotfiles/issues"
  echo

  while true; do
    local options=()
    options+=("Retry installation")
    options+=("View full log")
    options+=("Exit")

    choice=$(gum choose "${options[@]}" --header "What would you like to do?" --height 5 --padding "1 $PADDING_LEFT")

    case "$choice" in
    "Retry installation")
      bash "$KOJARCHY_DIR/install.sh"
      break
      ;;
    "View full log")
      if command -v less &>/dev/null; then
        less "$KOJARCHY_LOG"
      else
        tail "$KOJARCHY_LOG"
      fi
      ;;
    "Exit" | "")
      exit 1
      ;;
    esac
  done
}

exit_handler() {
  local exit_code=$?
  if [[ $exit_code -ne 0 && $ERROR_HANDLING != true ]]; then
    catch_errors
  else
    stop_log_output
    show_cursor
  fi
}

trap catch_errors ERR INT TERM
trap exit_handler EXIT

save_original_outputs
