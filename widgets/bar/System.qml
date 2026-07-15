import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick.Controls

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

        // --- Widget de Red ---
        IconImage {
            Layout.alignment: Qt.AlignHCenter // <- Esta es la magia para centrar
            implicitSize: 25
            source: {
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

            MouseArea {
                id: cycleMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    // Incrementamos el índice. QML detectará el cambio y actualizará
                    // automáticamente la portada, el título y la barra de progreso.
                    mediaWidget.currentPlayerIndex += 1
                }
            }
            ToolTip.visible: cycleMouse.containsMouse
            ToolTip.text: systemTrayRoot.wifiSig
        }

        // --- Widget de Bluetooth ---
        IconImage {
            Layout.alignment: Qt.AlignHCenter
            implicitSize: 25
            // Cambia el ícono dinámicamente si está apagado
            source: systemTrayRoot.btState === "On"
                    ? Quickshell.iconPath("bluetooth-active-symbolic")
                    : Quickshell.iconPath("bluetooth-disabled-symbolic")
        }

        // --- Widget de Batería ---
        // Cambié el Item por un ColumnLayout directo para manejar mejor el espacio interno
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 2 // Espacio fino entre el ícono y el texto del porcentaje

            IconImage {
                Layout.alignment: Qt.AlignHCenter
                implicitSize: 25
                source: {
                    // Lógica para cambiar el ícono según el nivel
                    if (systemTrayRoot.batStatus === "Charging") return Quickshell.iconPath("battery-level-100-charged-symbolic")
                    if (systemTrayRoot.batLevel > 80) return Quickshell.iconPath("battery-level-100-symbolic")
                    if (systemTrayRoot.batLevel > 50) return Quickshell.iconPath("battery-level-060-symbolic")
                    if (systemTrayRoot.batLevel > 20) return Quickshell.iconPath("battery-level-020-symbolic")
                    return Quickshell.iconPath("battery-empty-symbolic")
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 12
                text: systemTrayRoot.batLevel + "%"
            }
        }

        // Spacer inferior
        Item {
            Layout.fillHeight: true
        }
    }
}
