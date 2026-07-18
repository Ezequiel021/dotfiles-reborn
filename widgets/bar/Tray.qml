
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import "../theme"

Item {
    property bool isMenuShown: false
    property QsMenuHandle activeMenu: null
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

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton)
                        {
                            if (systemTrayRoot.activeMenu === modelData.menu && systemTrayRoot.isMenuShown) {
                                systemTrayRoot.isMenuShown = false;
                            }
                            else {
                                console.log(modelData.id);
                                systemTrayRoot.activeMenu = modelData.menu;
                                systemTrayRoot.isMenuShown = true;
                            }
                        }
                    }
                }
            }
        }
    }

    QsMenuOpener {
        id: dbusFetcher
        menu: systemTrayRoot.activeMenu
    }

    TrayMenu {
        id: trayMenu
        property bool isDataReady: dbusFetcher.children && dbusFetcher.children.values.length > 0
        
        visible: systemTrayRoot.isMenuShown && systemTrayRoot.activeMenu !== null && isDataReady
        trayItem: systemTrayRoot.activeMenu
        anchor.item: systemTrayRoot

        onCloseRequested: {
            systemTrayRoot.isMenuShown = false;
        }

        onIsDataReadyChanged: {
            if (isDataReady) console.log("Data ready!")
        }
    }
}