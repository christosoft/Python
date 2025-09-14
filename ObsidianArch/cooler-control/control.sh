#!/bin/bash

# Función para loguear mensajes
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> /opt/control-cooler/cooler-control.log
}

# Validación segura de enteros
to_int() {
    local input="$1"
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        echo "$input"
    else
        echo "0"
    fi
}

# Ajuste de bomba con validación
control_pump() {
    local speed="$1"

    if ! [[ "$speed" =~ ^[0-9]+$ ]]; then
        log_message "⚠️ Valor de velocidad inválido: '$speed'. Se omite ajuste."
        return
    fi

    if ! liquidctl --match "$DEVICE_NAME" set pump speed "$speed" 2>/dev/null; then
        log_message "❌ ERROR: Falló al ajustar bomba a $speed%"
    else
        log_message "💧 Bomba ajustada a ${speed}%"
    fi
}

# Ajuste de color según temperatura
set_cooler_color() {
    local raw_temp="$1"
    local temp_int
    temp_int=$(to_int "$raw_temp")

    if ! [[ "$temp_int" =~ ^[0-9]+$ ]]; then
        log_message "⚠️ Temperatura inválida: '$raw_temp'. Se omite cambio de color."
        return
    fi

    log_message "🎨 Ajustando color según temperatura: ${temp_int}°C"

    if [ "$temp_int" -lt "$CPU_LOW_TEMP" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed 00ff00
    elif [ "$temp_int" -lt "$((CPU_LOW_TEMP + 5))" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed 00ff33
    elif [ "$temp_int" -lt "$CPU_MEDIUM_TEMP" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed 0000ff
    elif [ "$temp_int" -lt "$((CPU_MEDIUM_TEMP + 5))" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed 0066ff
    elif [ "$temp_int" -lt "$CPU_HIGH_TEMP" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed ffff00
    elif [ "$temp_int" -lt "$((CPU_HIGH_TEMP + 2))" ]; then
        liquidctl --match "$DEVICE_NAME" set 1 color fixed ffa500
    else
        liquidctl --match "$DEVICE_NAME" set 1 color fixed ff0000
    fi
}
