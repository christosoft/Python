#!/bin/bash

log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE" 2>/dev/null
}

rotate_logs() {
    if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        log_message "📁 Log rotado"
    fi
}

check_dependencies() {
    local missing=()
    command -v sensors &>/dev/null || missing+=("lm-sensors")
    command -v liquidctl &>/dev/null || missing+=("liquidctl")
    [ ${#missing[@]} -gt 0 ] && log_message "❌ Faltan dependencias: ${missing[*]}" && return 1
    return 0
}

cleanup() {
    log_message "🛑 Apagando Cooler Control"
    control_pump $MEDIUM_SPEED
    liquidctl --match "$DEVICE_NAME" set 1 color fixed 0000ff 2>/dev/null
    exit 0
}
