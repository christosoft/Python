#!/bin/bash

source /opt/control-cooler/config.sh
source /opt/control-cooler/profiles.sh
source /opt/control-cooler/control.sh

get_max_temp() {
    local cpu_temp gpu_temp coolant_temp max_temp

    cpu_temp=$(sensors | grep 'Package id 0:' | awk '{print $4}' | tr -d '+°C')
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
    coolant_temp=$(liquidctl status | grep -i 'Coolant' | awk '{print $2}' | tr -d '°C')

    cpu_temp=$(to_int "$cpu_temp")
    gpu_temp=$(to_int "$gpu_temp")
    coolant_temp=$(to_int "$coolant_temp")

    max_temp=$cpu_temp
    ((gpu_temp > max_temp)) && max_temp=$gpu_temp
    ((coolant_temp > max_temp)) && max_temp=$coolant_temp

    echo "$max_temp"
}

get_active_profile() {
    local profile_file="/opt/control-cooler/cooler-profile.conf"
    if [ -f "$profile_file" ]; then
        source "$profile_file"
        echo "$PERFIL"
    else
        echo "auto"
    fi
}

main_loop() {
    while true; do
        local max_temp profile speed

        max_temp=$(get_max_temp)
        profile=$(get_active_profile)
        speed=$(get_speed_for_profile "$profile" "$max_temp")

        log_message "🔴 $profile | Max: ${max_temp}°C | Speed: ${speed}%"
        control_pump "$speed"
        set_cooler_color "$max_temp"
        log_message "🎛️ Perfil activo: $profile"

        sleep 10
    done
}

main_loop
