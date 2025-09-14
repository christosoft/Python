#!/bin/bash

SCRIPT_DIR="/opt/control-cooler"
[ -f "$SCRIPT_DIR/cooler-profile.conf" ] && source "$SCRIPT_DIR/cooler-profile.conf"
PERFIL="${PERFIL:-auto}"

set_profile_speeds() {
    case "$PERFIL" in
        gaming)
            LOW_SPEED=70; MEDIUM_SPEED=85; HIGH_SPEED=100; MAX_SPEED=100
            liquidctl --match "$DEVICE_NAME" set 1 color fixed ff00ff
            ;;      
        silent)
            LOW_SPEED=20; MEDIUM_SPEED=35; HIGH_SPEED=50; MAX_SPEED=60
            liquidctl --match "$DEVICE_NAME" set 1 color fixed 00ffff
            ;;
        basic)
            LOW_SPEED=35; MEDIUM_SPEED=50; HIGH_SPEED=65; MAX_SPEED=80
            liquidctl --match "$DEVICE_NAME" set 1 color fixed ffffcc
            ;;
        auto|*)
            LOW_SPEED=40; MEDIUM_SPEED=55; HIGH_SPEED=75; MAX_SPEED=100
            ;;
    esac
    log_message "🎛️ Perfil activo: $PERFIL"
}
