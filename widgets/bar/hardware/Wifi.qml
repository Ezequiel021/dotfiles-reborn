import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../../theme"

Item {
    id: networkWidgetRoot
    anchors.margins: 8

    // Propiedad reactiva para almacenar la lista de conexiones (arreglo de objetos)
    property var activeNetworks: []

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: 15
    }

    Process {
        id: nmStream
        command: ["bash", "/home/ramos/.config/quickshell/widgets/bar/scripts/nmstatus.sh"]
        running: true // Agregado para asegurar que el proceso inicie

        stdout: SplitParser {
            onRead: (data) => {
                if (data.trim() !== "") {
                    try {
                        // Inyectamos todo el arreglo JSON directamente al modelo
                        networkWidgetRoot.activeNetworks = JSON.parse(data);
                    } catch (e) {
                        console.log("Error parseando red:", e);
                    }
                }
            }
        }
    }

    // Contenedor principal para organizar la lista
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14 // Un poco de margen interno para que no toque los bordes del Rectangle
        spacing: 12

        // Generamos un elemento visual por cada conexión activa
        Repeater {
            model: networkWidgetRoot.activeNetworks

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Nombre de la red
                Rectangle {
                    radius: 12
                    color: Theme.surfaceVariant
                    Layout.fillWidth: true
                    Layout.preferredHeight: connectionLabel.height + 20

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 12
                        IconImage {
                            implicitSize: 40
                            source: {
                                if (modelData.type === "wifi")
                                    return Quickshell.iconPath("network-wireless")
                                else if (modelData.type === "ethernet")
                                    return Quickshell.iconPath("network-wired")
                            }
                        }
                        ColumnLayout {
                            id: connectionLabel
                            Layout.fillWidth: true

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: Theme.oNSurfaceVariant
                                font {
                                    pixelSize: 14
                                    family: "JetBrains Mono Nerd Font"
                                    bold: true
                                }
                                //elide: Text.ElideRight // Si el nombre de la red es muy largo, lo corta con "..."
                            }
                            Text {
                                color: Theme.oNSurfaceVariant
                                font {
                                    pixelSize: 11
                                    family: "JetBrains Mono Nerd Font"
                                }
                                text: modelData.device + "\n" + modelData.type
                            }
                        }
                    }
                }
            }
        }

        // Mensaje de fallback visible solo cuando el arreglo está vacío
        Text {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillHeight: true
            visible: networkWidgetRoot.activeNetworks.length === 0
            text: "Desconectado"
            color: Theme.oNPrimary
            font {
                pixelSize: 18
                family: "JetBrains Mono Nerd Font"
                bold: true
            }
        }

        // Spacer inferior: Empuja la lista hacia arriba si hay pocas conexiones
        Item {
            Layout.fillHeight: true
            visible: networkWidgetRoot.activeNetworks.length > 0
        }
    }
}