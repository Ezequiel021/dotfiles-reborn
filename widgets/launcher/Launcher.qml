import QtQuick
import Quickshell.Io
import qs.widgets.control
import qs.templates
import qs.theme // Assuming your theme modules
import qs.tokens
import Quickshell

Scope {
    id: launcherRoot

    // The IPC Handler lives at the root of the file.
    // It will always listen for the toggle command.
    IpcHandler {
        target: "launcher"
        function toggle() {
            launcherMenu.isOpen = !launcherMenu.isOpen;
        }
    }

    AnimatedPanel {
        id: launcherMenu
        isOpen: false
        edge: "bottom"
        panelWidth: 600
        panelHeight: 360

        // Because this Rectangle is the only unassigned object inside
        // AnimatedPanel, QML safely routes it to the contentComponent property.
        Rectangle {
            color: Theme.background
            topLeftRadius: Tokens.fullRadius
            topRightRadius: Tokens.fullRadius
            clip: true

            AppGrid {
                anchors.fill: parent
                onAppLaunched: launcherMenu.isOpen = false
            }
        }
    }
}