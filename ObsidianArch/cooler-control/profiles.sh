#!/bin/bash

get_speed_for_profile() {
    local profile="$1"
    local temp="$2"

    temp=$(to_int "$temp")

    case "$profile" in
        gaming)
            if [ "$temp" -lt 60 ]; then echo 70
            elif [ "$temp" -lt 75 ]; then echo 85
            else echo 100; fi
            ;;
        silent)
            if [ "$temp" -lt 45 ]; then echo 20
            elif [ "$temp" -lt 55 ]; then echo 35
            else echo 50; fi
            ;;
        basic)
            if [ "$temp" -lt 50 ]; then echo 35
            elif [ "$temp" -lt 65 ]; then echo 50
            else echo 65; fi
            ;;
        auto|*)
            if [ "$temp" -lt 50 ]; then echo 40
            elif [ "$temp" -lt 60 ]; then echo 55
            elif [ "$temp" -lt 70 ]; then echo 75
            else echo 100; fi
            ;;
    esac
}
