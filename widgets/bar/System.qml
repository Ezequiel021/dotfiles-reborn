import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: systemTrayRoot
    width: trayLayout.width
    height: 30

    // Propiedades reactivas para almacenar el estado
    property int batLevel: 0
    property string batStatus: "Unknown"
    property string wifiSsid: "Buscando..."
    property string btState: "Off"

    Process {
        id: sysStream
        // Asegúrate de colocar la ruta correcta hacia tu script
        command: ["bash", "~/.config/quickshell/widgets/bar/scripts/sys_status.sh"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data.trim() !== "") {
                    try {
                        let status = JSON.parse(data);
                        systemTrayRoot.batLevel = status.battery;
                        systemTrayRoot.batStatus = status.bat_status;
                        systemTrayRoot.wifiSsid = status.wifi;
                        systemTrayRoot.btState = status.bluetooth;
                    } catch (e) {
                        console.log("Error parseando el estado del sistema:", e);
                    }
                }
            }
        }
    }

    Column {
        id: trayLayout
        spacing: 16
        anchors.verticalCenter: parent.verticalCenter

        // --- Widget de Red ---
        Column {
            spacing: 6
            Text {
                // Puedes usar iconos de NerdFonts aquí (ej. 󰖩)
                text: "WIFI:" 
                IconImage
                color: systemTrayRoot.wifiSsid === "Desconectado" ? "#bf616a" : "#88c0d0"
                font.bold: true
            }
            Text {
                text: systemTrayRoot.wifiSsid
                color: "#eceff4"
            }
        }

        // --- Widget de Bluetooth ---
        Row {
            spacing: 6
            Text {
                text: "BT:"
                color: systemTrayRoot.btState === "On" ? "#88c0d0" : "#4c566a"
                font.bold: true
            }
            Text {
                text: systemTrayRoot.btState
                color: "#eceff4"
            }
        }

        // --- Widget de Batería ---
        Row {
            spacing: 6
            Text {
                text: systemTrayRoot.batStatus === "Charging" ? "CHR:" : "BAT:"
                // Cambia a rojo si hay poca batería y no está cargando
                color: (systemTrayRoot.batLevel < 20 && systemTrayRoot.batStatus !== "Charging") ? "#bf616a" : "#a3be8c"
                font.bold: true
            }
            Text {
                text: systemTrayRoot.batLevel + "%"
                color: "#eceff4"
            }
        }
    }
}