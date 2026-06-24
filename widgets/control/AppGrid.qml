import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: appListRoot

    // Propiedad interna para almacenar el texto de búsqueda en minúsculas
    property string filterText: ""

    // Contenedor principal vertical (Buscador arriba, Lista abajo)
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // ==========================================
        // 1. CAJA DE BÚSQUEDA (INPUT)
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            color: "#1affffff" // Fondo oscuro semi-transparente
            radius: 10
            border.color: searchInput.activeFocus ? "#66ffffff" : "#10ffffff"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 10

                // Icono de lupa (puedes usar un texto o un icono de tu tema)
                IconImage {
                    implicitSize: 16
                    source: Quickshell.iconPath("search-symbolic")
                }

                // El campo de texto real
                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    color: "white"
                    font.pixelSize: 14
                    focus: true // El buscador roba el foco automáticamente al abrir el panel
                    selectByMouse: true
                    
                    // Actualiza nuestra propiedad de filtrado en tiempo real
                    onTextChanged: appListRoot.filterText = text.toLowerCase()

                    // Texto de marcador de posición (Placeholder) cuando está vacío
                    Text {
                        text: "Search apps"
                        color: "#66ffffff"
                        font.pixelSize: 14
                        visible: searchInput.text === ""
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // ==========================================
        // 2. LISTA DE APLICACIONES FILTRADA
        // ==========================================
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6
            clip: true
            
            // CONECTAMOS EL MODELO:
            // Usamos DesktopEntries.applications como base
            model: DesktopEntries.applications
            
            delegate: Component {
                Item {
                    width: ListView.view.width
                    
                    // LÓGICA DE FILTRADO:
                    // Comprobamos si el nombre o la descripción contienen el texto del buscador.
                    // Si el buscador está vacío, se muestran todas (indexOf devuelve >= 0).
                    readonly property bool matchesFilter: 
                        modelData.name.toLowerCase().indexOf(appListRoot.filterText) !== -1 ||
                        (modelData.genericName && modelData.genericName.toLowerCase().indexOf(appListRoot.filterText) !== -1)

                    // Si no coincide, colapsamos la altura a 0 y lo ocultamos
                    height: matchesFilter ? 80 : 0
                    visible: matchesFilter

                    // Tu tarjeta (Mismo diseño del paso anterior)
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: matchesFilter ? 4 : 0 // Evita márgenes fantasma si está oculto
                        radius: 12
                        color: mouseArea.containsMouse ? "#25ffffff" : "#10ffffff"
                        border.color: mouseArea.containsMouse ? "#40ffffff" : "transparent"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 16

                            IconImage {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                Layout.alignment: Qt.AlignVCenter
                                source: Quickshell.iconPath(modelData.icon)
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.comment ? modelData.comment : "Application"
                                    color: "#b3ffffff"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                modelData.execute()
                                root.shouldShow = false
                            }
                        }
                    }
                }
            }
        }
    }
}