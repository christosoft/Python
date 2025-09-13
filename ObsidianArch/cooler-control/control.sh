#!/bin/bash

control_pump() {
    local speed=$1
    if ! liquidctl --match "$DEVICE_NAME" set pump speed "$speed" 2>/dev/null; then
        log_message "❌ ERROR: Falló al ajustar bomba a $speed%"
    else
        log_message "💧 Bomba ajustada a ${speed}%"
    fi
}

set_cooler_color() {
    local temp_int=$(to_int "$1")
    if [ "$temp_int" -lt "$CPU_LOW_TEMP" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed 00ff00
    elif [ "$temp_int" -lt "$((CPU_LOW_TEMP+5))" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed 00ff33
    elif [ "$temp_int" -lt "$CPU_MEDIUM_TEMP" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed 0000ff
    elif [ "$temp_int" -lt "$((CPU_MEDIUM_TEMP+5))" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed 0066ff
    elif [ "$temp_int" -lt "$CPU_HIGH_TEMP" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed ffff00
    elif [ "$temp_int" -lt "$((CPU_HIGH_TEMP+2))" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed ffa500
    else
        liquidctl --match "$DEVICE_NAME" set 1 color fixed ff0000
    fi
}
