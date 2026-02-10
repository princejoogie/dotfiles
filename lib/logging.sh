#!/bin/bash

# Kojarchy logging - install log, live tail display

start_log_output() {
  local ANSI_SAVE_CURSOR="\033[s"
  local ANSI_RESTORE_CURSOR="\033[u"
  local ANSI_CLEAR_LINE="\033[2K"
  local ANSI_HIDE_CURSOR="\033[?25l"
  local ANSI_RESET="\033[0m"
  local ANSI_GRAY="\033[90m"

  printf $ANSI_SAVE_CURSOR
  printf $ANSI_HIDE_CURSOR

  (
    local log_lines=20
    local max_line_width=$((LOGO_WIDTH - 4))

    while true; do
      mapfile -t current_lines < <(tail -n $log_lines "$KOJARCHY_LOG" 2>/dev/null)

      output=""
      for ((i = 0; i < log_lines; i++)); do
        line="${current_lines[i]:-}"
        if [ ${#line} -gt $max_line_width ]; then
          line="${line:0:$max_line_width}..."
        fi
        if [ -n "$line" ]; then
          output+="${ANSI_CLEAR_LINE}${ANSI_GRAY}${PADDING_LEFT_SPACES}  → ${line}${ANSI_RESET}\n"
        else
          output+="${ANSI_CLEAR_LINE}${PADDING_LEFT_SPACES}\n"
        fi
      done

      printf "${ANSI_RESTORE_CURSOR}%b" "$output"
      sleep 0.1
    done
  ) &
  monitor_pid=$!
}

stop_log_output() {
  if [ -n "${monitor_pid:-}" ]; then
    kill $monitor_pid 2>/dev/null || true
    wait $monitor_pid 2>/dev/null || true
    unset monitor_pid
  fi
}

start_install_log() {
  sudo touch "$KOJARCHY_LOG"
  sudo chmod 666 "$KOJARCHY_LOG"

  export KOJARCHY_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  echo "=== Kojarchy Installation Started: $KOJARCHY_START_TIME ===" >>"$KOJARCHY_LOG"
  start_log_output
}

stop_install_log() {
  stop_log_output
  show_cursor

  if [[ -n ${KOJARCHY_LOG:-} ]]; then
    KOJARCHY_END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "=== Kojarchy Installation Completed: $KOJARCHY_END_TIME ===" >>"$KOJARCHY_LOG"
    echo "" >>"$KOJARCHY_LOG"

    echo "=== Installation Time Summary ===" >>"$KOJARCHY_LOG"

    if [ -n "$KOJARCHY_START_TIME" ]; then
      KOJARCHY_START_EPOCH=$(date -d "$KOJARCHY_START_TIME" +%s)
      KOJARCHY_END_EPOCH=$(date -d "$KOJARCHY_END_TIME" +%s)
      KOJARCHY_DURATION=$((KOJARCHY_END_EPOCH - KOJARCHY_START_EPOCH))

      KOJARCHY_MINS=$((KOJARCHY_DURATION / 60))
      KOJARCHY_SECS=$((KOJARCHY_DURATION % 60))

      echo "Kojarchy:    ${KOJARCHY_MINS}m ${KOJARCHY_SECS}s" >>"$KOJARCHY_LOG"
    fi
    echo "=================================" >>"$KOJARCHY_LOG"
  fi
}

run_logged() {
  local script="$1"
  export CURRENT_SCRIPT="$script"

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting: $script" >>"$KOJARCHY_LOG"

  bash -c "source '$KOJARCHY_DIR/lib/helpers.sh'; source '$script'" </dev/null >>"$KOJARCHY_LOG" 2>&1

  local exit_code=$?

  if [ $exit_code -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Completed: $script" >>"$KOJARCHY_LOG"
    unset CURRENT_SCRIPT
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed: $script (exit code: $exit_code)" >>"$KOJARCHY_LOG"
  fi

  return $exit_code
}
