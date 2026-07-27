import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.widgets.control
import qs.templates
import qs.theme
import qs.tokens

Scope {
    id: root
    property bool shouldShow: false

    IpcHandler {
        target: "launcher"
        function toggle() {
            root.shouldShow ^= 1;
        }
    }

    LazyLoader {
        active: root.shouldShow
        PanelWindow {
            id: panel
            implicitHeight: 360
            implicitWidth: 600
            color: "transparent"
            anchors.bottom: true
            exclusionMode: ExclusionMode.Ignore

            focusable: true

            HyprlandFocusGrab {
                id: grab
                windows: [panel]
                active: root.shouldShow
                onCleared: {
                    root.shouldShow = false
                }
            }

            StyledRect {
                anchors.fill: parent
                color: Theme.background
                topLeftRadius: Tokens.fullRadius
                topRightRadius: Tokens.fullRadius
            }

            AppGrid {
                anchors.fill: parent
            }
        }
    }
}