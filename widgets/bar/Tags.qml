import QtQuick
import Quickshell.Widgets
import Quickshell
import QtQuick.Layouts
import Quickshell.Io
import qs.theme
import qs.tokens
import QtQuick.Effects
import QtQuick.Controls

Item {
    id: workspaceRoot
    property var tagsModel: []

    Process {
        id: tagsStream
        command: ["mmsg", "watch", "all-tags"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (data.trim() !== "") {
                    try {
                        let parsed = JSON.parse(data);

                        // Verificamos que la estructura sea válida y extraemos los tags del monitor principal (índice 0)
                        if (parsed.all_tags && parsed.all_tags.length > 0) {
                            workspaceRoot.tagsModel = parsed.all_tags[0].tags;
                        }
                    } catch (e) {
                        console.log("Error parseando el JSON de mmsg:", e);
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.primary_container
        anchors.margins: Tokens.containerMargins
        radius: 20
    }

    ColumnLayout {
        anchors.centerIn: parent
        id: colLayout
        spacing: 6

        Repeater {
            model: workspaceRoot.tagsModel
            //Layout.alignment: Qt.AlignHCenter

            delegate: Item {
                implicitHeight: 24
                implicitWidth: 24

                Button {
                    anchors.centerIn: parent
                    anchors.fill: parent
                    background: Rectangle {
                        radius: 12

                        // Mapeo exacto basado en el JSON de MangoWM
                        color: {
                            if (modelData.is_urgent) return "#bf616a"; // Rojo: Requiere atención
                            if (modelData.is_active) return Theme.primary;
                            if (modelData.client_count > 0) return "transparent"; // Gris: Inactivo pero con ventanas
                            return "transparent"; // Vacío
                        }
                    }

                    icon {
                        width: 15
                        height: 15
                        source: (modelData.client_count > 0 || modelData.is_active) ? "" : Quickshell.iconPath("media-record-symbolic")
                        color: Theme.on_primary_container
                    }

                    font {
                        family: "JetBrains Mono Nerd Font"
                        bold: true
                        pixelSize: 16
                    }

                    palette.buttonText: (modelData.is_active) ? Theme.on_primary : Theme.on_primary_container

                    text: (modelData.is_active || modelData.client_count > 0) ? modelData.index : ""
                }
            }
        }
    }
}
