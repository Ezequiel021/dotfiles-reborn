import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.tokens
import qs.theme
import qs.templates

// 1. EL ENVOLTORIO: Recibe los 500px del AnimatedPopup sin quejarse
Item {
    id: menuWrapper
    clip: true

    required property QsMenuHandle trayItem

    signal menuEntered()
    signal menuExited()

    // 2. EL MENÚ REAL: Protegido dentro del envoltorio
    StackView {
        id: view

        // Lo centramos respecto al envoltorio de 500px
        anchors.centerIn: parent

        // Aquí mantenemos el tamaño estrictamente ligado al contenido
        width: Tokens.trayMenuWidth
        height: currentItem ? currentItem.implicitHeight : 0

        Behavior on height {
            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }

        HoverHandler {
            id: menuHoverHandler
            onHoveredChanged: hovered ? menuWrapper.menuEntered() : menuWrapper.menuExited()
        }

        // Superficie visual MD3
        Rectangle {
            anchors.fill: parent
            color: Theme.secondary_container
            radius: 12
            border.color: Theme.outline_variant
            border.width: 1
        }

        initialItem: SubMenu {
            handle: menuWrapper.trayItem
            isSubMenu: false
        }

        Component {
            id: subMenuComp
            SubMenu {}
        }

        component NoAnim: Transition {
            NumberAnimation { duration: 0 }
        }

        pushEnter: null
        pushExit: null
        popEnter: null
        popExit: null

        // =========================================================
        // Componente del Menú ajustado al contenido
        // =========================================================
        component SubMenu: Column {
            id: menu

            required property QsMenuHandle handle
            property bool isSubMenu: false

            readonly property real horizontalPadding: 8
            readonly property real verticalPadding: 8

            width: view.width
            topPadding: verticalPadding
            bottomPadding: verticalPadding
            leftPadding: horizontalPadding
            rightPadding: horizontalPadding
            spacing: 2

            QsMenuOpener {
                id: menuOpener
                menu: menu.handle
            }

            // --- Botón "Atrás" para Submenús ---
            Rectangle {
                id: backBtn
                visible: menu.isSubMenu
                width: menu.width - (menu.horizontalPadding * 2)
                height: visible ? 24 : 0
                radius: 12
                color: backMouse.containsMouse ? Theme.secondary : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8
                    visible: menu.isSubMenu

                    MaterialIcon {
                        source: "arrow_back"
                        font.pixelSize: 18
                        color: backMouse.containsMouse ? Theme.on_secondary : Theme.on_secondary_container
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Atrás"
                        font.bold: true
                        color: backMouse.containsMouse ? Theme.on_secondary : Theme.on_secondary_container
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: view.pop()
                }
            }

            Item {
                width: 1
                height: menu.isSubMenu ? 2 : 0
                visible: menu.isSubMenu
            }

            // --- Lista de Elementos del Menú ---
            Repeater {
                model: menuOpener.children

                Rectangle {
                    id: itemRect
                    required property QsMenuEntry modelData

                    width: menu.width - (menu.horizontalPadding * 2)
                    height: modelData.isSeparator ? 9 : 24
                    radius: 12

                    color: {
                        if (modelData.isSeparator || !modelData.enabled) return "transparent";
                        return itemMouse.containsMouse ? Theme.secondary : "transparent";
                    }

                    QsMenuOpener {
                        id: subMenuPreFetcher
                        menu: itemRect.modelData.hasChildren ? itemRect.modelData : null
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 8
                        height: 1
                        color: Theme.on_secondary_container
                        opacity: 0.5
                        visible: itemRect.modelData.isSeparator
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12
                        visible: !itemRect.modelData.isSeparator

                        IconImage {
                            id: icon
                            Layout.preferredWidth: visible ? 18 : 0
                            Layout.preferredHeight: visible ? 18 : 0
                            visible: itemRect.modelData.icon !== ""
                            source: visible ? itemRect.modelData.icon : ""
                        }

                        Text {
                            id: label
                            Layout.fillWidth: true
                            text: itemRect.modelData.text
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter

                            color: {
                                if (!itemRect.modelData.enabled) return Theme.on_secondary_container_fixed;
                                return itemMouse.containsMouse ? Theme.on_secondary : Theme.on_secondary_container;
                            }
                        }

                        MaterialIcon {
                            id: expandIndicator
                            Layout.preferredWidth: visible ? 18 : 0
                            Layout.preferredHeight: visible ? 18 : 0
                            visible: itemRect.modelData.hasChildren
                            source: "chevron_right"
                            font.pixelSize: 20

                            color: {
                                if (!itemRect.modelData.enabled) return Theme.on_secondary_fixed;
                                return itemMouse.containsMouse ? Theme.on_secondary : Theme.on_secondary_container;
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: itemRect.modelData.enabled
                        enabled: itemRect.modelData.enabled

                        onClicked: {
                            const entry = itemRect.modelData;
                            if (entry.hasChildren) {
                                if (subMenuPreFetcher.children && subMenuPreFetcher.children.values.length > 0) {
                                    view.push(subMenuComp, { handle: entry, isSubMenu: true });
                                }
                            } else {
                                entry.triggered();
                                // Asumo que `root` es un ID externo de tu ventana principal.
                                root.closeRequested();
                            }
                        }
                    }
                }
            }
        }
    }
}
