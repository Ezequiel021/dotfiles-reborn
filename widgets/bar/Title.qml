pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Item {
    id: windowTitleRoot
    implicitHeight: titleText.implicitWidth
    implicitWidth: 38

    property string activeTitle: "Desktop"

    Process {
    id: mangoStream
    // Reemplazamos el comando antiguo por la sintaxis moderna
    command: ["mmsg", "watch", "focusing-client"]
    running: true

    stdout: SplitParser {
        onRead: (data) => {
            if (data.trim() !== "") {
                try {
                    // Convertimos la salida de mmsg en un objeto manipulable
                    let client = JSON.parse(data);
                    
                    // Asignamos el título si existe, de lo contrario mostramos el escritorio
                    if (client.title && client.title.trim() !== "") {
                        windowTitleRoot.activeTitle = client.title;
                    } else {
                        windowTitleRoot.activeTitle = "Desktop";
                    }
                } catch (e) {
                    // Evita que la barra colapse si mmsg escupe un JSON malformado
                    console.log("Error leyendo el IPC de MangoWM:", e);
                }
            }
        }
    }
}

    Text {
        font.family: "JetBrains Mono Nerd Font"
        id: titleText
        anchors.centerIn: parent
        text: windowTitleRoot.activeTitle
        color: Theme.oNPrimaryContainer
        width: 285
        elide: Text.ElideRight
    }
}