import QtQuick
import Quickshell.Hyprland
import QtQuick.Layouts
import QtQuick.Controls
import qs.tokens
import qs.theme

Item {
    id: root
    property var currentMonitor 
    
    property int maxWorkspaces: 5
    property int workspaceSize: 24
    property int workspaceSpacing: 6
    property int stride: workspaceSize + workspaceSpacing
    
    // Calculates the required height to fit exactly 5 items based on their stride
    property int viewHeight: maxWorkspaces * stride 

    width: workspaceSize + Tokens.containerMargins * 2
    height: viewHeight + Tokens.containerMargins * 2

    // 1. The Main Background
    Rectangle {
        anchors.fill: parent
        anchors.margins: Tokens.containerMargins
        color: Theme.primary_container
        radius: 20
    }

    // 2. The Static Highlight (Always in the dead center)
    Rectangle {
        id: centerHighlight
        anchors.centerIn: parent
        width: root.workspaceSize
        height: root.workspaceSize
        radius: width / 2
        color: Theme.primary
    }

    // 3. The Cyclic Scrolling PathView
    PathView {
        id: pathView
        anchors.centerIn: parent
        width: root.workspaceSize
        height: root.viewHeight
        
        // Clip to ensure scrolling items fade out cleanly at the edges
        clip: true

        model: Hyprland.workspaces
        
        // Enforce the 5-item visible limit
        pathItemCount: root.maxWorkspaces
        
        // Lock the current index strictly to the 50% mark of the path (the center)
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange
        
        // Allows the user to scroll through workspaces with the mouse/touchpad
        interactive: true
        movementDirection: PathView.Shortest

        // A straight vertical path from top to bottom
        path: Path {
            startX: pathView.width / 2
            startY: 0
            PathLine { 
                x: pathView.width / 2
                y: pathView.height 
            }
        }

        delegate: Item {
            id: delegateItem
            width: root.workspaceSize
            height: root.workspaceSize

            // Check if this workspace belongs to the current monitor
            property bool isOnCorrectMonitor: modelData.monitor === Hyprland.monitorFor(root.currentMonitor)
            property bool isActuallyActive: modelData.active && isOnCorrectMonitor
            
            visible: isOnCorrectMonitor

            // When this workspace becomes active, tell the PathView to center it
            onIsActuallyActiveChanged: {
                if (isActuallyActive) {
                    pathView.currentIndex = index
                }
            }
            
            Component.onCompleted: {
                if (isActuallyActive) {
                    pathView.currentIndex = index
                }
            }

            // Visual polish: fade and shrink items that aren't the center (active) item
            opacity: PathView.isCurrentItem ? 1.0 : 0.5
            scale: PathView.isCurrentItem ? 1.0 : 0.8
            
            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

            Button {
                anchors.fill: parent
                
                background: Rectangle {
                    radius: width / 2
                    color: "#bf616a" // Urgent state color
                    opacity: modelData.urgent ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                font {
                    family: "0xProto Nerd Font"
                    bold: true
                    pixelSize: 16
                }

                palette.buttonText: delegateItem.PathView.isCurrentItem ? Theme.on_primary : Theme.on_primary_container
                text: modelData.name

                onClicked: {
                    modelData.activate()
                }
            }
        }
    }
}