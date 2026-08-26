import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.tokens
import qs.theme
import qs.templates

StackView {
    id: view

    // 1. Altura máxima segura para la superficie visual del menú (puedes ajustarla)
    readonly property real maxMenuHeight: 520

    // 2. Anclaje y tamaño estricto: El ancho es fijo, la altura se adapta hasta el tope máximo
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: Tokens.trayMenuWidth
    implicitHeight: Math.min(currentItem?.implicitHeight ?? 0, maxMenuHeight)

    required property QsMenuHandle trayItem

    signal menuEntered()
    signal menuExited()

    HoverHandler {
        id: menuHoverHandler
        onHoveredChanged: hovered ? view.menuEntered() : view.menuExited()
    }

    // 3. Superficie visual MD3: Se adapta al alto DINÁMICO de la vista, no a la ventana transparente
    Rectangle {
        anchors.fill: parent
        color: Theme.secondary_container
        radius: 12
        border.color: Theme.outline_variant
        border.width: 1
    }

    initialItem: SubMenu {
        handle: view.trayItem
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
    // Componente del Menú con soporte de Scroll (ScrollView)
    // =========================================================
    component SubMenu: ScrollView {
        id: menu

        required property QsMenuHandle handle
        property bool isSubMenu: false

        readonly property real fixedHorizontalPadding: 8
        readonly property real fixedVerticalPadding: 8

        // El ScrollView toma el tamaño disponible del StackView
        width: Tokens.trayMenuWidth
        implicitHeight: contentColumn.implicitHeight + (fixedVerticalPadding * 2)

        // Se activa el corte visual solo si el contenido supera el área visible
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        QsMenuOpener {
            id: menuOpener
            menu: menu.handle
        }

        Column {
            id: contentColumn
            width: menu.width
            topPadding: menu.fixedVerticalPadding
            bottomPadding: menu.fixedVerticalPadding
            leftPadding: menu.fixedHorizontalPadding
            rightPadding: menu.fixedHorizontalPadding
            spacing: 2

            // --- Botón "Atrás" para Submenús ---
            Loader {
                active: menu.isSubMenu
                width: parent.width - (menu.fixedHorizontalPadding * 2)
                sourceComponent: Column {
                    width: parent.width
                    spacing: 4

                    Rectangle {
                        id: backBtn
                        width: parent.width
                        height: 24
                        radius: 12
                        color: backMouse.containsMouse ? Theme.secondary : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

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
                }
            }

            // --- Lista de Elementos del Menú ---
            Repeater {
                model: menuOpener.children

                Rectangle {
                    id: itemRect
                    required property QsMenuEntry modelData

                    width: contentColumn.width - (contentColumn.leftPadding + contentColumn.rightPadding)
                    height: modelData.isSeparator ? 9 : 24
                    radius: 12

                    color: {
                        if (modelData.isSeparator) return "transparent";
                        if (!modelData.enabled) return "transparent";
                        return itemMouse.containsMouse ? Theme.secondary : "transparent"
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
                                if (!itemRect.modelData.enabled) return Theme.on_secondary_container_fixed
                                return itemMouse.containsMouse ? Theme.on_secondary : Theme.on_secondary_container
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
                                if (!itemRect.modelData.enabled) return Theme.on_secondary_fixed
                                return itemMouse.containsMouse ? Theme.on_secondary : Theme.on_secondary_container
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: itemRect.modelData.enabled
                        enabled: itemRect.modelData.enabled

                        onClicked: {
                            const entry = itemRect.modelData
                            if (entry.hasChildren) {
                                if (subMenuPreFetcher.children && subMenuPreFetcher.children.values.length > 0) {
                                    view.push(subMenuComp, { handle: entry, isSubMenu: true })
                                }
                            } else {
                                entry.triggered()
                                root.closeRequested()
                            }
                        }
                    }
                }
            }
        }
    }
}
