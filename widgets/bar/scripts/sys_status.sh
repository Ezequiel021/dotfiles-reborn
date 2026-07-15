#!/bin/bash
# sys_status.sh

while true; do
    # Batería: Leemos directamente del kernel (reemplaza BAT0 o BAT1 según tu sistema)
    BAT_CAP=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo "0")
    BAT_STAT=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1 || echo "Unknown")

    # Red: Usamos nmcli para obtener el SSID del Wi-Fi activo
    WIFI_SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 | head -n 1)
    if [ -z "$WIFI_SSID" ]; then
        WIFI_SSID="Desconectado"
    else
        WIFI_INTENSITY=$(nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^\*' | cut -d: -f2)
    fi

    # Bluetooth: Verificamos si el controlador está encendido
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        BT_STAT="On"
    else
        BT_STAT="Off"
    fi

    # Construimos y emitimos el JSON
    echo "{\"battery\": $BAT_CAP, \"bat_status\": \"$BAT_STAT\", \"wifi\": \"$WIFI_SSID\", \"wifi_intensity\": \"$WIFI_INTENSITY\", \"bluetooth\": \"$BT_STAT\"}"
    
    # Pausamos 3 segundos antes de volver a consultar para no consumir CPU
    sleep 3
done