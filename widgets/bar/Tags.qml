
import QtQuick
import Quickshell
import Quickshell.Io

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

    Column {
        id: rowLayout
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: workspaceRoot.tagsModel

            delegate: Rectangle {
                width: 24
                height: 24
                radius: 4
                
                // Mapeo exacto basado en el JSON de MangoWM
                color: {
                    if (modelData.is_urgent) return "#bf616a";     // Rojo: Requiere atención
                    if (modelData.is_active) return "#88c0d0";     // Azul: Tag actual enfocado
                    if (modelData.client_count > 0) return "#4c566a"; // Gris: Inactivo pero con ventanas
                    return "transparent";                          // Vacío
                }
                
                border.color: "#81a1c1"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    // Usamos la llave 'index' que provee el JSON
                    text: modelData.index 
                    color: modelData.is_active ? "#2e3440" : "#eceff4"
                }
            }
        }
    }
}
