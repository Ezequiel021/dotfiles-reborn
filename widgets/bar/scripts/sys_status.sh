#!/bin/bash
# sys_status.sh

while true; do
    # --- Batería ---
    BAT_CAP=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1 || echo "0")
    BAT_STAT=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1 || echo "Unknown")

    # --- Bluetooth ---
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        BT_STAT="On"
    else
        BT_STAT="Off"
    fi

    # --- Intensidad del Wi-Fi ---
    # Obtenemos la señal de la red activa (0 si no hay conexión)
    WIFI_INTENSITY=$(nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | grep '^\*' | cut -d: -f2 | head -n 1)
    if [ -z "$WIFI_INTENSITY" ]; then 
        WIFI_INTENSITY=0 
    fi

    # --- Redes (JSON Array) ---
    NETWORKS_JSON=$(nmcli -t -f STATE,DEVICE,TYPE,CONNECTION dev 2>/dev/null | grep '^connected:' | awk -F':' -v sig="$WIFI_INTENSITY" '
    BEGIN { 
        printf "[" 
        first = 1 
    }
    {
        if (!first) { printf "," }
        
        name = $4
        for (i=5; i<=NF; i++) { name = name ":" $i }
        gsub(/"/, "\\\"", name)

        # Si es Wi-Fi, agregamos la propiedad "signal" al JSON
        if ($3 == "wifi") {
            printf "{\"state\":\"%s\",\"device\":\"%s\",\"type\":\"%s\",\"name\":\"%s\",\"signal\":%d}", $1, $2, $3, name, sig
        } else {
            printf "{\"state\":\"%s\",\"device\":\"%s\",\"type\":\"%s\",\"name\":\"%s\"}", $1, $2, $3, name
        }
        
        first = 0
    }
    END { 
        printf "]" 
    }')

    # Salvaguarda: si awk no devuelve nada, usamos un arreglo vacío
    if [ -z "$NETWORKS_JSON" ]; then 
        NETWORKS_JSON="[]" 
    fi

    # --- Emitimos el JSON Maestro ---
    echo "{\"battery\": $BAT_CAP, \"bat_status\": \"$BAT_STAT\", \"bluetooth\": \"$BT_STAT\", \"networks\": $NETWORKS_JSON}"
    
    sleep 3
done