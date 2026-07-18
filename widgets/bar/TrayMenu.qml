pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import qs.tokens
import "../theme"

Loader {
    PopupWindow {
    id: root

    color: "transparent"

    signal closeRequested()
    required property QsMenuHandle trayItem

    implicitHeight: view.implicitHeight
    implicitWidth: view.implicitWidth

    anchor {
        edges: Edges.Right
        gravity: Edges.Right
    }

    Rectangle {
        anchors.fill: parent
        topRightRadius: 20
        bottomRightRadius: 20
        color: Theme.secondary_container
    }

    StackView {
        id: view
        implicitWidth: currentItem?.implicitWidth ?? 0
        implicitHeight: currentItem?.implicitHeight ?? 0

        initialItem: SubMenu {
            handle: root.trayItem
        }

        Component {
            id: subMenuComp
            SubMenu {}
        }

        component NoAnim: Transition {
            NumberAnimation {
                duration: 0
            }
        }

        pushEnter: null
        pushExit: null
        popEnter: null
        popExit: null
    }

    component SubMenu: Column {
        id: menu

        required property QsMenuHandle handle
        property bool isSubMenu: false

        padding: 3
        spacing: 3

        QsMenuOpener {
            id: menuOpener
            menu: menu.handle
        }

        Repeater {
            model: menuOpener.children

            Rectangle {
                QsMenuOpener {
                    id: subMenuPreFetcher
                    menu: itemRect.modelData.hasChildren ? itemRect.modelData : null
                }

                id: itemRect
                required property QsMenuEntry modelData

                implicitWidth: Tokens.trayMenuWidth

                implicitHeight: modelData.isSeparator ? 1 : Math.max(30, label.implicitHeight + 12)

                radius: 8

                color: {
                    if (modelData.isSeparator) return Theme.secondary_container;
                    if (itemMouse.containsMouse) return Theme.secondary;
                    return "transparent";
                }

                Item {
                    anchors.fill: parent
                    visible: !itemRect.modelData.isSeparator

                    IconImage {
                        id: icon
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter

                        visible: itemRect.modelData.icon !== ""
                        source: visible ? itemRect.modelData.icon : ""

                        implicitWidth: visible ? 16 : 0
                        implicitHeight: visible ? 16 : 0
                    }

                    Text {
                        id: label

                        anchors.left: icon.visible ? icon.right : parent.left
                        anchors.leftMargin: icon.visible ? 8 : 8

                        anchors.right: expandIndicator.visible ? expandIndicator.left : parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter

                        text: itemRect.modelData.text
                        color: itemRect.modelData.enabled ? Theme.on_secondary_container : "gray"

                        elide: Text.ElideRight
                    }

                    Text {
                        id: expandIndicator
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter

                        visible: itemRect.modelData.hasChildren
                        text: ">"
                        color: itemRect.modelData.enabled ? Theme.on_secondary_container : "gray"
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            const entry = itemRect.modelData;
                            if (entry.hasChildren) {
                                if (subMenuPreFetcher.children && subMenuPreFetcher.children.values.length > 0) {
                                    view.push(subMenuComp, {handle: entry, isSubMenu: true});
                                }
                            } else {
                                entry.triggered();
                                root.closeRequested()
                            }
                        }
                    }
                }
            }
        }

        Loader {
            asynchronous: true
            active: menu.isSubMenu

            sourceComponent: Item {
                implicitWidth: back.implicitWidth
                implicitHeight: back.implicitHeight + 1

                Item {
                    anchors.bottom: parent.bottom
                    implicitWidth: back.implicitWidth
                    implicitHeight: back.implicitHeight

                    Rectangle {
                        radius: 8
                        color: Theme.secondary
                        implicitWidth: parent.width
                        implicitHeight: parent.height
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: view.pop()
                    }

                    Row {
                        id: back
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "<"
                            color: Theme.on_secondary
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Back"
                            color: Theme.on_secondary
                        }
                    }
                }
            }
        }
    }
}
}