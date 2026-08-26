import Quickshell
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root

    // --- Public API ---
    property bool isOpen: false
    property string edge: "bottom" // Accepts: "top", "bottom", "left", "right"
    property int panelWidth: 600
    property int panelHeight: 360

    // Captures whatever QML is nested inside the component block
    default property Component contentComponent

    // Watch isOpen to trigger the LazyLoader immediately on open
    onIsOpenChanged: {
        if (isOpen) {
            containerLoader.activeAsync = true;
        }
    }

    LazyLoader {
        id: containerLoader
        activeAsync: false

        PanelWindow {
            id: panel
            implicitHeight: root.panelHeight
            implicitWidth: root.panelWidth
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            focusable: true

            // Quickshell uses booleans to bind to screen edges
            anchors.top: root.edge === "top"
            anchors.bottom: root.edge === "bottom"
            anchors.left: root.edge === "left"
            anchors.right: root.edge === "right"

            Item {
                id: container
                property bool isReady: false

                width: parent.width
                height: parent.height

                // Calculate slide origins based on the chosen edge
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

                // Renders the widgets you passed into the wrapper
                Loader {
                    anchors.fill: parent
                    sourceComponent: root.contentComponent
                }
            }
        }
    }
}
