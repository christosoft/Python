#!/bin/bash

to_int() { echo "${1%%.*}"; }

get_cpu_temp() {
    local temp=$(sensors 2>/dev/null | grep 'Package id 0:' | awk '{print $4}' | sed 's/[+°C]//g')
    [[ "$temp" =~ ^[0-9]+(\.[0-9]+)?$ ]] || temp=$(sensors | grep 'Core [0-9]:' | awk '{print $3}' | sed 's/[+°C]//g' | sort -nr | head -1)
    echo "${temp:-0}"
}

get_gpu_temp() {
    local temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null)
    [[ "$temp" =~ ^[0-9]+(\.[0-9]+)?$ ]] && echo "$temp" || echo "0"
}

get_coolant_temp() {
    for i in {1..3}; do
        local temp=$(liquidctl --match "$DEVICE_NAME" status 2>/dev/null | grep -i 'liquid temperature' | awk '{print $4}' | sed 's/°C//')
        [[ "$temp" =~ ^[0-9]+(\.[0-9]+)?$ ]] && echo "$temp" && return
        sleep 1
    done
    echo "0"
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
