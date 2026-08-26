import QtQuick
import Quickshell
import Quickshell.Hyprland // Necesario para HyprlandFocusGrab

Scope {
    id: root
    property bool isOpen: false
    property int popupWidth: 100
    property int popupHeight: 100
    property string edge: "left" // "top", "bottom", "left", "right"

    default property Component contentComponent
    property Item anchorItem

    onIsOpenChanged: {
        if (isOpen) {
            containerLoader.activeAsync = true;
        }
    }

    LazyLoader {
        id: containerLoader
        activeAsync: false

        PopupWindow {
            id: popup
            height: root.popupHeight
            width: root.popupWidth
            color: "transparent" // Corregido para evitar un fondo blanco durante la animación
            visible: container.isReady

            anchor {
                item: root.anchorItem
                edges: {
                    if (root.edge === "left") return Edges.Right
                    if (root.edge === "right") return Edges.Left
                    if (root.edge === "top") return Edges.Bottom
                    if (root.edge === "bottom") return Edges.Top
                    return Edges.Right
                }
                gravity: Edges.Right
            }

            Item {
                id: container
                property bool isReady: false

                width: parent.width
                height: parent.height

                property real hiddenX: root.edge === "left" ? -width : (root.edge === "right" ? width : 0)
                property real hiddenY: root.edge === "top" ? -height : (root.edge === "bottom" ? height : 0)

                state: (root.isOpen && isReady) ? "visible" : "hidden"

                Component.onCompleted: {
                    isReady = true;
                }

                states: [
                    State {
                        name: "visible"
                        PropertyChanges { container.opacity: 1.0; container.x: 0; container.y: 0 }
                    },
                    State {
                        name: "hidden"
                        PropertyChanges { container.opacity: 0.0; container.x: container.hiddenX; container.y: container.hiddenY }
                    }
                ]

                transitions: [
                    Transition {
                        from: "hidden"; to: "visible"
                        NumberAnimation { properties: "x,y,opacity"; duration: 300; easing.type: Easing.OutCubic }
                    },
                    Transition {
                        from: "visible"; to: "hidden"

                        SequentialAnimation {
                            NumberAnimation {
                                properties: "x,y,opacity"
                                duration: 250
                                easing.type: Easing.InCubic
                            }

                            ScriptAction {
                                script: {
                                    if (!root.isOpen) {
                                        containerLoader.activeAsync = false;
                                    }
                                }
                            }
                        }
                    }
                ]

                Loader {
                    anchors.fill: parent
                    sourceComponent: root.contentComponent
                }
            }
        }
    }
}
