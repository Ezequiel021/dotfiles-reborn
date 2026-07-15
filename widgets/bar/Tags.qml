
import QtQuick
import Quickshell.Widgets
import Quickshell
import QtQuick.Layouts
import Quickshell.Io
import "../theme"
import QtQuick.Effects

Item {
    id: workspaceRoot
    width: rowLayout.width
    height: 30

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

    ColumnLayout {
        anchors.centerIn: parent
        id: rowLayout
        spacing: 8

        Repeater {
            model: workspaceRoot.tagsModel
            Layout.alignment: Qt.AlignHCenter

            delegate: Rectangle {
                width: 24
                height: 24
                radius: 4
                
                // Mapeo exacto basado en el JSON de MangoWM
                color: {
                    if (modelData.is_urgent) return "#bf616a";     // Rojo: Requiere atención
                    if (modelData.is_active) return Theme.primary;     // Azul: Tag actual enfocado
                    if (modelData.client_count > 0) return "transparent"; // Gris: Inactivo pero con ventanas
                    return "transparent";                          // Vacío
                }

                Text {
                    font {
                        family: "JetBrains Mono Nerd Font"
                        bold: true
                    }

                    anchors.centerIn: parent
                    visible: modelData.client_count > 0 || modelData.is_active ? true : false

                    text: modelData.index
                    color: modelData.is_active ? Theme.oNPrimary : Theme.oNPrimaryContainer
                }

                IconImage {
                    id: rawIcon
                    visible: modelData.client_count || modelData.is_active > 0 ? false : true

                    width: 15
                    height: 15
                    anchors.centerIn: parent
                    source: Quickshell.iconPath("media-record-symbolic")

                    MultiEffect {
                        anchors.fill: parent
                        source: parent
                        brightness: 0.4
                        // colorization a 1.0 indica que queremos teñir la imagen al 100%
                        colorization: 1.0
                        colorizationColor: Theme.oNPrimaryContainer
                    }
                }

                
            }
        }
    }
}
