import QtQuick
import Quickshell.Hyprland
import QtQuick.Layouts
import QtQuick.Controls
import qs.tokens
import qs.theme
import Quickshell

Item {
    id: root
    required property var currentMonitor
    Rectangle {
        width: colLayout.implicitWidth + Tokens.containerMargins * 2
        height: colLayout.implicitHeight + Tokens.containerMargins * 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Tokens.containerMargins
        anchors.top: parent.top
        color: Theme.primary_container
        anchors.margins: Tokens.containerMargins
        radius: 20

        Behavior on height {
            NumberAnimation {
                easing: Easing.OutCubic
                duration: Tokens.expressiveAnimDuration
            }
        }
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 16
        id: colLayout
        spacing: 6

        Repeater {
            model: Hyprland.workspaces

            delegate: Item {

                visible: modelData.monitor === Hyprland.monitorFor(root.currentMonitor)
                height: modelData.monitor === Hyprland.monitorFor(root.currentMonitor) ? 24 : 0
                implicitWidth: 24

                Button {

                    anchors.centerIn: parent
                    anchors.fill: parent
                    background: Rectangle {
                        radius: 12

                        color: {
                            if (modelData.urgent) return "#bf616a";
                            if (modelData.active && modelData.monitor === Hyprland.monitorFor(root.currentMonitor)) return Theme.primary;
                            if (modelData.client_count > 0) return "transparent";
                            return "transparent"; 
                        }
                    }

                    font {
                        family: "JetBrains Mono Nerd Font"
                        bold: true
                        pixelSize: 16
                    }

                    palette.buttonText: (modelData.active && modelData.monitor === Hyprland.monitorFor(root.currentMonitor)) ? Theme.on_primary : Theme.on_primary_container

                    text: (modelData.active || modelData.toplevels.values.length > 0) ? modelData.id : ""
                }
            }
        }
    }
}