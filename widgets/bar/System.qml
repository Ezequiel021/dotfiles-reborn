import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtQuick.Controls
import "../theme"
import qs.widgets.bar.hardware

Item {
    id: systemTrayRoot
    height: 30
    anchors {
        fill: parent
        margins: 5
    }

    property bool contentHovered: (battery.isHovered || wifi.isHovered || bluetooth.isHovered)

    Rectangle {
        id: bgRect
        color: Theme.primary_container

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        // Si hay hover, le sumamos 5px al ancho para que toque el borde de la ventana de Quickshell
        width: parent.width + (systemTrayRoot.contentHovered ? 5 : 0)

        radius: 20
        // Aplanamos las esquinas derechas para fusionarnos con el popup
        bottomRightRadius: systemTrayRoot.contentHovered ? 0 : 20
        topRightRadius: systemTrayRoot.contentHovered ? 0 : 20

        // Animaciones suaves para la transición geométrica
        Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on bottomRightRadius { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on topRightRadius { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    }

    // Propiedades reactivas para almacenar el estado
    property int batLevel: 0
    property string batStatus: "Unknown"
    property string wifiSsid: "Buscando..."
    property string btState: "Off"
    property int wifiSig: 100
    property bool activeHover: false

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
                        systemTrayRoot.btState = status.bluetooth;
                        
                        // INYECCIÓN MÁGICA: Pasamos el arreglo completo al widget de red
                        wifiWidget.activeNetworks = status.networks;
                    } catch (e) {
                        console.log("Error parseando el estado del sistema:", e);
                    }
                }
            }
        }
    }

    PopupWindow {
        id: contextMenu
        visible: popupBg.opacity > 0
        color: "transparent"
        implicitWidth: popupContainer.width
        implicitHeight: popupContainer.height

        // qmllint disable missing-type
        anchor {
            item: systemTrayRoot
            edges: Edges.Right
            gravity: Edges.Right
        }
        // qmllint enable missing-type

        Item {
            id: popupContainer
            implicitWidth: popupBg.width + 5
            implicitHeight: popupBg.height

            Rectangle {
                id: popupBg
                x: systemTrayRoot.contentHovered ? 5 : -10
                opacity: systemTrayRoot.contentHovered ? 1.0 : 0.0
                
                // Optimizamos la transición
                Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                color: Theme.primary_container
                topLeftRadius: 0
                bottomLeftRadius: 0
                topRightRadius: 20
                bottomRightRadius: 20
                
                // === Optimización: Ancho fijo con clip ===
                clip: true 
                width: wifi.isHovered ? 316 : tooltipTextDisplay.implicitWidth + 24
                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                
                height: systemTrayRoot.height

                Wifi {
                    id: wifiWidget
                    // Fijamos el ancho para que no se recalcule durante la animación
                    width: 300 
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    visible: wifi.isHovered
                }

                Text {
                    visible: (!wifi.isHovered)
                    id: tooltipTextDisplay
                    anchors.centerIn: parent
                    text: {
                        if (battery.isHovered) return battery.tooltipText
                        if (wifi.isHovered) return wifi.tooltipText
                        if (bluetooth.isHovered) return bluetooth.tooltipText
                        return "Error!"
                    }
                    color: Theme.on_primary_container

                    font {
                        pixelSize: 16
                        family: "JetBrains Mono"
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: trayLayout
        spacing: 10
        anchors.fill: parent

        // Spacer superior para empujar todo hacia el centro
        Item {
            Layout.fillHeight: true
        }

        TrayIcon {
            id: wifi
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 32

            // Inyectamos el ícono dinámico
            iconSource: wifiWidget.panelIcon

            // Inyectamos el texto de la tooltip
            tooltipText: "Red: " + systemTrayRoot.wifiSsid
            iconColor: Theme.on_primary_container
        }

        // --- Widget de Bluetooth ---
        TrayIcon {
            id: bluetooth
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 32

            iconSource: systemTrayRoot.btState === "On"
                        ? Quickshell.iconPath("bluetooth-active-symbolic")
                        : Quickshell.iconPath("bluetooth-disabled-symbolic")
            tooltipText: "Bluetooth: " + (systemTrayRoot.btState === "On" ? "Encendido" : "Apagado")
            iconColor: Theme.on_primary_container
        }

        // --- Widget de Batería ---
        TrayIcon {
            id: battery
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 32
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
            iconColor: Theme.on_primary_container
        }

        // Spacer inferior
        Item {
            Layout.fillHeight: true
        }
    }
}
