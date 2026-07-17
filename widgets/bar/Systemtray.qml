pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray

Item {
    id: systemTrayRoot
    Rectangle {
        id: systemTrayBg
        anchors.fill: parent
        color: "grey"
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayDelegate
                implicitHeight: 32
                implicitWidth: 32
                
                property var trayItem: modelData

                Image {
                    anchors.fill: parent
                    source: trayDelegate.trayItem.icon
                    fillMode: Image.PreserveAspectFit
                }

                // 1. Reemplazamos Popup por PopupWindow
                PopupWindow {

                    anchor {
                        item: systemTrayRoot
                        edges: Edges.Right
                        gravity: Edges.Right
                    }

                    id: menuPopup
                    
                    // Al ser una ventana, definimos su tamaño directamente
                    width: 220
                    height: stack.implicitHeight + 16 // +16 para compensar los márgenes (8px arriba y abajo)
                    
                    // 2. Controlamos su visibilidad como ventana, no como componente
                    visible: false
                    
                    // 3. Fondo transparente para que el compositor Wayland no dibuje 
                    // esquinas negras detrás de nuestros bordes redondeados
                    color: "transparent" 

                    Shortcut {
                        sequence: "Escape"
                        onActivated: menuPopup.visible = false
                    }

                    onVisibleChanged: {
                        if (visible) {
                            requestActivate(); // Solicita el foco a Wayland al abrirse
                        }
                    }

                    // Contenedor principal que dibuja nuestro diseño
                    Rectangle {
                        anchors.fill: parent
                        color: "#ffffff"
                        radius: 8
                        border.color: "#cccccc"
                        
                        // Un Item interno para replicar el "padding" que nos daba el componente Popup
                        Item {
                            anchors.fill: parent
                            anchors.margins: 8

                            StackView {
                                id: stack
                                anchors.fill: parent

                                implicitWidth: currentItem ? currentItem.implicitWidth : 0
                                implicitHeight: currentItem ? currentItem.implicitHeight : 0
                                
                                pushEnter: Transition { NumberAnimation { duration: 150; property: "opacity"; from: 0; to: 1 } }
                                popEnter: Transition { NumberAnimation { duration: 150; property: "opacity"; from: 0; to: 1 } }
                                
                                initialItem: subMenuComp
                                
                                Component.onCompleted: {
                                    stack.initialItem = stack.push(subMenuComp, { handle: trayDelegate.trayItem.menu, isSubMenu: false })
                                }
                            }
                        }
                    }

                    Component {
                        id: subMenuComp

                        Column {
                            id: menuCol
                            required property var handle
                            property bool isSubMenu: false
                            
                            spacing: 4
                            width: stack.width

                            QsMenuOpener {
                                id: menuOpener
                                menu: menuCol.handle
                            }

                            Loader {
                                active: menuCol.isSubMenu
                                width: parent.width
                                sourceComponent: Item {
                                    width: parent.width
                                    implicitHeight: 30
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        color: backMouse.containsMouse ? "#eeeeee" : "transparent"
                                        radius: 4
                                    }
                                    
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: 8
                                        text: "← Atrás"
                                        font.bold: true
                                    }
                                    
                                    MouseArea {
                                        id: backMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: stack.pop()
                                    }
                                }
                            }

                            Repeater {
                                model: menuOpener.children

                                delegate: Item {
                                    id: menuItem
                                    required property var modelData 
                                    
                                    width: menuCol.width
                                    implicitHeight: modelData.isSeparator ? 1 : 30

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#dddddd"
                                        visible: menuItem.modelData.isSeparator
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: itemMouse.containsMouse ? "#eeeeee" : "transparent"
                                        radius: 4
                                        visible: !menuItem.modelData.isSeparator
                                        opacity: menuItem.modelData.enabled ? 1.0 : 0.5

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8

                                            Text {
                                                Layout.fillWidth: true
                                                text: menuItem.modelData.text
                                                elide: Text.ElideRight
                                                color: "black"
                                            }

                                            Text {
                                                text: "▶"
                                                visible: menuItem.modelData.hasChildren
                                                font.pixelSize: 10
                                                color: "gray"
                                            }
                                        }

                                        MouseArea {
                                            id: itemMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            enabled: menuItem.modelData.enabled

                                            onClicked: {
                                                const entry = menuItem.modelData;
                                                if (entry.hasChildren) {
                                                    stack.push(subMenuComp, {
                                                        handle: entry,
                                                        isSubMenu: true
                                                    });
                                                } else {
                                                    entry.triggered();
                                                    // 4. Cerramos la ventana modificando visible
                                                    menuPopup.visible = false;
                                                    stack.pop(null); 
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton) {
                            if (trayDelegate.trayItem.hasMenu) {
                                if (menuPopup.visible) {
                                    // Si ya está abierto, lo cerramos
                                    menuPopup.visible = false;
                                } else {
                                    // Si está cerrado, lo anclamos, lo abrimos y reseteamos el stack
                                    menuPopup.anchor.rect = trayDelegate.mapToItem(null, 0, 0, trayDelegate.width, trayDelegate.height);
                                    stack.pop(null); // Asegura que siempre abra en la raíz
                                    menuPopup.visible = true;
                                }
                            }
                        } else if (mouse.button === Qt.LeftButton) {
                            trayDelegate.trayItem.activate(mouse.x, mouse.y);
                        }
                    }
                }
            }
        }
    }
}