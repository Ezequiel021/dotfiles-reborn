#!/bin/bash

while true; do
nmcli -t -f STATE,DEVICE,TYPE,CONNECTION dev | grep '^connected:' | awk -F':' '
BEGIN {
    # Iniciamos el arreglo sin salto de línea
    printf "["
    first = 1
}
{
    # Si no es el primero, imprimimos una coma (sin salto)
    if (!first) {
        printf ","
    }
    
    name = $4
    for (i=5; i<=NF; i++) {
        name = name ":" $i
    }
    gsub(/"/, "\\\"", name)

    # Imprimimos el objeto compactado
    printf "{\"state\":\"%s\",\"device\":\"%s\",\"type\":\"%s\",\"name\":\"%s\"}", $1, $2, $3, name
    
    first = 0
}
END {
    # Cerramos el arreglo y enviamos el ÚNICO salto de línea para activar el SplitParser
    printf "]\n"
}'
sleep 5
done