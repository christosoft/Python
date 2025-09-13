#!/bin/bash

SCRIPT_DIR="/opt/control-cooler"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/profiles.sh"
source "$SCRIPT_DIR/sensors.sh"
source "$SCRIPT_DIR/control.sh"

trap cleanup EXIT INT TERM
rotate_logs
log_message "🚀 Iniciando Cooler Control para i5-4690K"

check_dependencies || exit 1
liquidctl --match "$DEVICE_NAME" initialize

while true; do
    rotate_logs
    set_profile_speeds  # ← lee perfil dinámico

    local max_temp=$(get_max_temp)
    local cpu=$(get_cpu_temp)
    local coolant=$(get_coolant_temp)
    local gpu=$(get_gpu_temp)
    local hottest=$(get_hottest_component)

    local speed status emoji
    local max_int=$(to_int "$max_temp")

    if [ "$max_int" -eq 0 ]; then
        speed=$MEDIUM_SPEED; status="SAFE"; emoji="⚪"
    elif [ "$max_int" -lt "$CPU_LOW_TEMP" ]; then
        speed=$LOW_SPEED; status="LOW"; emoji="🟢"
    elif [ "$max_int" -lt "$CPU_MEDIUM_TEMP" ]; then
        speed=$MEDIUM_SPEED; status="MEDIUM"; emoji="🔵"
    elif [ "$max_int" -lt "$CPU_HIGH_TEMP" ]; then
        speed=$HIGH_SPEED; status="HIGH"; emoji="🟡"
    else
        speed=$MAX_SPEED; status="MAX"; emoji="🔴"
    fi

    log_message "${emoji} ${status} | Max: ${max_temp}°C | CPU: ${cpu}°C | Coolant: ${coolant}°C | GPU: ${gpu}°C | Speed: ${speed}%"
    control_pump "$speed"
    set_cooler_color "$max_temp"

    sleep 10
done
