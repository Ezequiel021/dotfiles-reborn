import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../theme"

Item {
    id: networkWidgetRoot
    anchors.margins: 8

    // 1. Recibimos los datos desde System.qml
    property var activeNetworks: []

    // 2. Extraemos dinámicamente las redes
    property var ethNet: activeNetworks ? activeNetworks.find(n => n.type === "ethernet") : null
    property var wifiNet: activeNetworks ? activeNetworks.find(n => n.type === "wifi") : null

    // 3. Lógica de prioridad e intensidad para el ícono de la barra
    property string panelIcon: {
        if (ethNet) return Quickshell.iconPath("network-wired-symbolic")
        
        if (wifiNet) {
            let sig = wifiNet.signal || 0;
            if (sig > 80) return Quickshell.iconPath("network-wireless-signal-excellent-symbolic")
            if (sig > 60) return Quickshell.iconPath("network-wireless-signal-good-symbolic")
            if (sig > 40) return Quickshell.iconPath("network-wireless-signal-ok-symbolic")
            if (sig > 20) return Quickshell.iconPath("network-wireless-signal-weak-symbolic")
            return Quickshell.iconPath("network-wireless-signal-none-symbolic")
        }
        
        return Quickshell.iconPath("network-wireless-offline-symbolic")
    }
    
    property string tooltipText: {
        if (ethNet) return "Red: " + ethNet.name
        if (wifiNet) return "Red: " + wifiNet.name
        return "Desconectado"
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 15
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // ==========================================
        // TARJETA ETHERNET
        // ==========================================
        Rectangle {
            radius: 12
            color: Theme.surface_variant
            
            // MAGIA DE LAYOUT: Expansión horizontal y vertical
            Layout.fillWidth: true
            Layout.fillHeight: true 
            
            opacity: networkWidgetRoot.ethNet ? 1.0 : 0.5

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12
                
                IconImage {
                    implicitSize: 48
                    source: networkWidgetRoot.ethNet 
                            ? Quickshell.iconPath("network-wired") 
                            : Quickshell.iconPath("network-wired-offline-symbolic")
                }
                
                ColumnLayout {
                    id: ethColumn
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: networkWidgetRoot.ethNet ? networkWidgetRoot.ethNet.name : "Sin conexión"
                        color: Theme.on_surface_variant
                        font {
                            pixelSize: 14
                            family: "JetBrains Mono Nerd Font"
                            bold: true
                        }
                    }
                    Text {
                        color: Theme.on_surface_variant
                        font {
                            pixelSize: 11
                            family: "JetBrains Mono Nerd Font"
                        }
                        text: networkWidgetRoot.ethNet ? (networkWidgetRoot.ethNet.device + "\n" + networkWidgetRoot.ethNet.type) : "Ethernet"
                    }
                }
            }
        }

        // ==========================================
        // TARJETA WI-FI
        // ==========================================
        Rectangle {
            radius: 12
            color: Theme.surface_variant
            
            // MAGIA DE LAYOUT: Expansión horizontal y vertical
            Layout.fillWidth: true
            Layout.fillHeight: true 
            
            opacity: networkWidgetRoot.wifiNet ? 1.0 : 0.5

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12
                
                IconImage {
                    implicitSize: 48
                    source: networkWidgetRoot.wifiNet 
                            ? Quickshell.iconPath("network-wireless") 
                            : Quickshell.iconPath("network-wireless-offline-symbolic")
                }
                
                ColumnLayout {
                    id: wifiColumn
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: networkWidgetRoot.wifiNet ? networkWidgetRoot.wifiNet.name : "Desconectado"
                        color: Theme.on_surface_variant
                        font {
                            pixelSize: 14
                            family: "JetBrains Mono Nerd Font"
                            bold: true
                        }
                    }
                    Text {
                        color: Theme.on_surface_variant
                        font {
                            pixelSize: 11
                            family: "JetBrains Mono Nerd Font"
                        }
                        text: networkWidgetRoot.wifiNet ? (networkWidgetRoot.wifiNet.device + "\n" + networkWidgetRoot.wifiNet.type) : "Wi-Fi"
                    }
                }
            }
        }
    }
}