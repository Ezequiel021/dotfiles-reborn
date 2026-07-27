import QtQuick
import Quickshell.Hyprland
import QtQuick.Layouts
import QtQuick.Controls
import qs.tokens
import qs.theme

Item {
    anchors.topMargin: Tokens.containerMargins
    id: root
    property var currentMonitor 
    
    // Track the currently active workspace delegate to know where to move the highlight
    property Item activeDelegate: null

    // 1. The Main Background
    Rectangle {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }

        height: colLayout.implicitHeight + Tokens.containerMargins * 2
        width: colLayout.implicitWidth + Tokens.containerMargins * 2

        color: Theme.primary_container
        radius: 20
    }

    // 2. The Sliding Highlight (Placed BEFORE the buttons so it renders behind them)
    Rectangle {
        id: slidingHighlight
        width: 24
        height: 24
        radius: 12
        color: Theme.primary
        
        // Dynamically calculate position relative to the root Item
        x: activeDelegate ? colLayout.x + activeDelegate.x : colLayout.x
        y: activeDelegate ? colLayout.y + activeDelegate.y : colLayout.y
        
        // Hide it if nothing is active on this monitor
        opacity: activeDelegate ? 1.0 : 0.0
        
        // The magic happens here: Animate the Y coordinate whenever it changes
        Behavior on y {
            NumberAnimation { duration: 250; easing.type: Easing.OutExpo }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    // 3. The Workspaces Layout
    ColumnLayout {
        id: colLayout
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: Tokens.containerMargins
        }

        spacing: 6

        Repeater {
            model: Hyprland.workspaces

            delegate: Item {
                id: delegateItem
                
                // Helper property to check if THIS specific workspace is active on THIS monitor
                property bool isActive: modelData.active && modelData.monitor === Hyprland.monitorFor(root.currentMonitor)

                visible: modelData.monitor === Hyprland.monitorFor(root.currentMonitor)
                implicitHeight: visible ? 24 : 0
                implicitWidth: visible ? 24 : 0

                // When this becomes the active workspace, tell the root to track it
                onIsActiveChanged: {
                    if (isActive) root.activeDelegate = delegateItem
                }
                
                // Catch the initial state when the widget first loads
                Component.onCompleted: {
                    if (isActive) root.activeDelegate = delegateItem
                }
                
                // Safety check: if a workspace is destroyed while active, clear the tracker
                Component.onDestruction: {
                    if (root.activeDelegate === delegateItem) root.activeDelegate = null
                }

                Button {
                    anchors.centerIn: parent
                    anchors.fill: parent
                    
                    // We now only handle the URGENT state here. 
                    // The active highlight is handled by the slidingRectangle behind this.
                    background: Rectangle {
                        radius: 12
                        color: "#bf616a"
                        opacity: modelData.urgent ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    font {
                        family: "JetBrains Mono Nerd Font"
                        bold: true
                        pixelSize: 16
                    }

                    palette.buttonText: delegateItem.isActive ? Theme.on_primary : Theme.on_primary_container
                    
                    text: (modelData.active || modelData.toplevels.values.length > 0) ? modelData.id : ""

                    onClicked: {
                        modelData.activate()
                    }
                }
            }
        }
    }
}