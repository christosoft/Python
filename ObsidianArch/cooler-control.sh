#!/bin/bash

# ================= CONFIGURACIÓN ==================
CPU_LOW_TEMP=45
CPU_MEDIUM_TEMP=65
CPU_HIGH_TEMP=80

LOW_SPEED=40
MEDIUM_SPEED=55
HIGH_SPEED=75
MAX_SPEED=100

LOG_FILE="/var/log/cooler-control.log"
MAX_LOG_SIZE=1048576

# ================= FUNCIONES ==================

to_int() {
    echo "${1%%.*}"
}

log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE" 2>/dev/null
}

rotate_logs() {
    if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        log_message "📁 Log rotated"
    fi
}

get_cpu_temp() {
    local temp=$(sensors 2>/dev/null | grep 'Package id 0:' | awk '{print $4}' | sed 's/[+°C]//g' | tr -d '\n')
    [[ "$temp" =~ ^[0-9]+(\.[0-9]+)?$ ]] || temp=$(sensors | grep 'Core [0-9]:' | awk '{print $3}' | sed 's/[+°C]//g' | sort -nr | head -1)
    echo "${temp:-0}"
}

get_coolant_temp() {
    for i in {1..3}; do
        local temp=$(liquidctl --match "H100i GTX" status 2>/dev/null | grep -i 'liquid temperature' | awk '{print $4}' | sed 's/°C//')
        [[ "$temp" =~ ^[0-9]+(\.[0-9]+)?$ ]] && echo "$temp" && return
        sleep 1
    done
    echo "0"
}

get_gpu_temp() {
    local temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null)
    [[ "$temp" =~ ^[0-9]+(\.[0-9]+)?$ ]] && echo "$temp" || echo "0"
}

get_max_temp() {
    local cpu=$(get_cpu_temp)
    local coolant=$(get_coolant_temp)
    local gpu=$(get_gpu_temp)
    echo $(printf "%s\n" "$cpu" "$coolant" "$gpu" | sort -nr | head -1)
}

get_hottest_component() {
    local cpu=$(get_cpu_temp)
    local coolant=$(get_coolant_temp)
    local gpu=$(get_gpu_temp)
    if (( $(echo "$cpu >= $coolant" | bc -l) )) && (( $(echo "$cpu >= $gpu" | bc -l) )); then echo "CPU"
    elif (( $(echo "$gpu >= $cpu" | bc -l) )) && (( $(echo "$gpu >= $coolant" | bc -l) )); then echo "GPU"
    else echo "Coolant"
    fi
}

control_pump() {
    local speed=$1
    if ! liquidctl --match "H100i GTX" set pump speed "$speed" 2>/dev/null; then
        log_message "❌ ERROR: Failed to set pump speed (tried $speed%)"
    else
        log_message "💧 Pump set to ${speed}%"
    fi
}

set_cooler_color() {
    local temp_int=$(to_int "$1")
    if [ "$temp_int" -lt "$CPU_LOW_TEMP" ]; then
        liquidctl --match "H100i GTX" set 1 color fixed 00ff00
    elif [ "$temp_int" -lt "$((CPU_LOW_TEMP+5))" ]; then
        liquidctl --match "H100i GTX" set 1 color fixed 00ff33
    elif [ "$temp_int" -lt "$CPU_MEDIUM_TEMP" ]; then
        liquidctl --match "H100i GTX" set 1 color fixed 0000ff
    elif [ "$temp_int" -lt "$((CPU_MEDIUM_TEMP+5))" ]; then
        liquidctl --match "H100i GTX" set 1 color fixed 0066ff
    elif [ "$temp_int" -lt "$CPU_HIGH_TEMP" ]; then
        liquidctl --match "H100i GTX" set 1 color fixed ffff00
    elif [ "$temp_int" -lt "$((CPU_HIGH_TEMP+2))" ]; then
        liquidctl --match "H100i GTX" set 1 color fixed ffa500
    else
        liquidctl --match "H100i GTX" set 1 color fixed ff0000
    fi
}

adjust_all_cooling() {
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

    echo "{\"text\": \"$emoji $hottest\", \"tooltip\": \"🌡️ Max Temp: ${max_temp}°C\n🧠 CPU: ${cpu}°C\n💧 Coolant: ${coolant}°C\n🎮 GPU: ${gpu}°C\"}"
}

check_dependencies() {
    local missing=()
    command -v sensors &>/dev/null || missing+=("lm-sensors")
    command -v liquidctl &>/dev/null || missing+=("liquidctl")
    [ ${#missing[@]} -gt 0 ] && log_message "❌ Missing: ${missing[*]}" && return 1
    return 0
}

cleanup() {
    log_message "🛑 Shutting down cooler control"
    control_pump $MEDIUM_SPEED
    liquidctl --match "H100i GTX" set 1 color fixed 0000ff 2>/dev/null
    exit 0
}

# ================= MAIN ==================
trap cleanup EXIT INT TERM
rotate_logs
log_message "🚀 Starting Cooler Control for i5-4690K"

check_dependencies || exit 1
liquidctl --match "H100i GTX" initialize 2>/dev/null

while true; do
    rotate_logs
    adjust_all_cooling
    sleep 10
done
