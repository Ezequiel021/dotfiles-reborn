
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import qs.tokens
import qs.theme
import qs.templates

Item {
    property bool isMenuShown: false
    property QsMenuHandle activeMenu: null
    id: systemTrayRoot
    property Item activeAnchorItem: null

    onIsMenuShownChanged: {
        if (isMenuShown) console.log("Mostrando menu")
    }

    Timer {
        id: globalHideTimer
        interval: 350
        repeat: false

        onTriggered: {
            systemTrayRoot.isMenuShown = false;
            if (typeof popupWindowLoader !== "undefined") {
                trayMenuPopup.active = false;
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayDelegate
                implicitHeight: 32
                implicitWidth: 32

                property var trayItem: modelData

                Image {
                    id: trayIcon
                    anchors.fill: parent
                    source: trayDelegate.trayItem.icon
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent

                    // 1. Habilitamos la detección de movimiento del cursor sin hacer clic
                    hoverEnabled: true

                    // 2. Lógica al entrar el cursor (Hover)
                    onEntered: {
                        globalHideTimer.stop() // Frena el cierre si regresas al icono
                        
                        if (systemTrayRoot.activeMenu !== modelData.menu || !systemTrayRoot.isMenuShown) {
                            systemTrayRoot.activeMenu = modelData.menu;
                            systemTrayRoot.activeAnchorItem = trayDelegate
                            systemTrayRoot.isMenuShown = true;
                            trayMenuPopup.isOpen = true;
                        }
                    }

                    onExited: {
                        globalHideTimer.start() // Inicia cuenta regresiva al salir del icono
                    }
                }
            }
        }
    }

    QsMenuOpener {
        id: dbusFetcher
        menu: systemTrayRoot.activeMenu
    }

    AnimatedPopup {
        id: trayMenuPopup
        isOpen: systemTrayRoot.isMenuShown
        anchorItem: systemTrayRoot.activeAnchorItem
        TrayMenu {
                    anchors.centerIn: parent
                    id: trayMenu
                    property bool isDataReady: dbusFetcher.children && dbusFetcher.children.values.length > 0
                    trayItem: systemTrayRoot.activeMenu

                    visible: systemTrayRoot.activeMenu !== null

                    // Cuando el usuario entra al menú flotante, cancelamos el cierre
                    onMenuEntered: globalHideTimer.stop()
                    
                    // Si el usuario sale del menú flotante, iniciamos el cierre
                    onMenuExited: globalHideTimer.start()
                }
    }
}