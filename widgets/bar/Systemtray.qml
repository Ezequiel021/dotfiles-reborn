import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell // Necesario para usar QsMenuAnchor
import Quickshell.Services.SystemTray

Item {
    Rectangle {
        anchors.fill: parent
        color: "grey"
    }

    ColumnLayout {
        anchors.centerIn: parent
        id: colLayout
        spacing: 6

        Repeater {
            model: SystemTray.items

            delegate: Item {
                implicitHeight: 32
                implicitWidth: 32

                // 1. Enlaza el menú nativo del SystemTrayItem al widget
                QsMenuAnchor {
                    id: menuAnchor
                    menu: modelData.menu
                }

                Image {
                    anchors.fill: parent
                    source: modelData.icon
                    fillMode: Image.PreserveAspectFit
                }

                // 2. Gestiona los clics izquierdo y derecho
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            // Despliega el menú contextual si la aplicación tiene uno
                            if (modelData.hasMenu) {
                                menuAnchor.open();
                            }
                        } else if (mouse.button === Qt.LeftButton) {
                            // Ejecuta la acción por defecto de la aplicación
                            modelData.activate();
                        }
                    }
                }
            }
        }
    }
}