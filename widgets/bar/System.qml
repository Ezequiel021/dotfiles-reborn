import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtQuick.Controls
import "../theme"

Item {
    id: systemTrayRoot
    width: trayLayout.width
    height: 30
    
    // Propiedades reactivas para almacenar el estado
    property int batLevel: 0
    property string batStatus: "Unknown"
    property string wifiSsid: "Buscando..."
    property string btState: "Off"
    property int wifiSig: 100

    Process {
        id: sysStream
        // Asegúrate de colocar la ruta correcta hacia tu script
        command: ["bash", "/home/ramos/.config/quickshell/widgets/bar/scripts/sys_status.sh"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data.trim() !== "") {
                    try {
                        let status = JSON.parse(data);
                        systemTrayRoot.batLevel = status.battery;
                        systemTrayRoot.batStatus = status.bat_status;
                        systemTrayRoot.wifiSsid = status.wifi;
                        systemTrayRoot.wifiSig = status.wifi_intensity
                        systemTrayRoot.btState = status.bluetooth;
                    } catch (e) {
                        console.log("Error parseando el estado del sistema:", e);
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: trayLayout
        spacing: 16
        anchors.fill: parent

        // Spacer superior para empujar todo hacia el centro
        Item {
            Layout.fillHeight: true
        }

        TrayIcon {
            Layout.alignment: Qt.AlignHCenter

            // Inyectamos el ícono dinámico
            iconSource: {
                if (systemTrayRoot.wifiSsid === "Desconectado" || systemTrayRoot.wifiSsid === "Buscando...") {
                    return Quickshell.iconPath("network-wireless-offline-symbolic")
                }
                else {
                    if (systemTrayRoot.wifiSig > 80) return Quickshell.iconPath("network-wireless-signal-excellent-symbolic")
                    if (systemTrayRoot.wifiSig > 60) return Quickshell.iconPath("network-wireless-signal-good-symbolic")
                    if (systemTrayRoot.wifiSig > 40) return Quickshell.iconPath("network-wireless-signal-ok-symbolic")
                    if (systemTrayRoot.wifiSig > 20) return Quickshell.iconPath("network-wireless-signal-weak-symbolic")
                    else return Quickshell.iconPath("network-wireless-signal-none-symbolic")
                }
            }

            // Inyectamos el texto de la tooltip
            tooltipText: "Red: " + systemTrayRoot.wifiSsid
            iconColor: Theme.oNPrimaryContainer
        }

        // --- Widget de Bluetooth ---
        TrayIcon {
            Layout.alignment: Qt.AlignHCenter
            iconSource: systemTrayRoot.btState === "On"
                        ? Quickshell.iconPath("bluetooth-active-symbolic")
                        : Quickshell.iconPath("bluetooth-disabled-symbolic")
            tooltipText: "Bluetooth: " + (systemTrayRoot.btState === "On" ? "Encendido" : "Apagado")
            iconColor: Theme.oNPrimaryContainer
        }

        Button {
            background: Rectangle {
                color: "transparent"
            }
            Layout.fillWidth: true
            icon.source: systemTrayRoot.btState === "On"
                        ? Quickshell.iconPath("bluetooth-active-symbolic")
                        : Quickshell.iconPath("bluetooth-disabled-symbolic")
            icon.color: Theme.oNPrimaryContainer
        }

        // --- Widget de Batería ---
        TrayIcon {
            Layout.alignment: Qt.AlignHCenter
            iconSource: {
                if (systemTrayRoot.batStatus === "Charging") return Quickshell.iconPath("battery-level-100-charged-symbolic")
                if (systemTrayRoot.batLevel > 80) return Quickshell.iconPath("battery-level-100-symbolic")
                if (systemTrayRoot.batLevel > 50) return Quickshell.iconPath("battery-level-060-symbolic")
                if (systemTrayRoot.batLevel > 20) return Quickshell.iconPath("battery-level-020-symbolic")
                return Quickshell.iconPath("battery-empty-symbolic")
            }

            // Tooltip detallada para la batería
            tooltipText: "Batería: " + systemTrayRoot.batLevel + "%" +
                         (systemTrayRoot.batStatus === "Charging" ? " (Cargando)" : "")
            iconColor: Theme.oNPrimaryContainer
        }

        // Spacer inferior
        Item {
            Layout.fillHeight: true
        }
    }
}
