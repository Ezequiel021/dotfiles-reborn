import Quickshell
import QtQuick
import QtQuick.Layouts
import "../theme/"

// qmllint disable uncreatable-type
Scope {
    Variants {
        model: Quickshell.screens;

        PanelWindow {
            required property var modelData
            screen: modelData

            color: Theme.background
            
            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: 48

            ColumnLayout {
                anchors {
                    fill: parent
                }

                // ======= Tags =======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 5
                    Layout.preferredHeight: 300
                    color: Theme.primaryContainer
                    radius: 8
                    Tags {
                        anchors.centerIn: parent
                    }
                }

                // ======= Title =======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 5
                    Layout.fillHeight: true
                    color: Theme.primaryContainer
                    radius: 8
                    Title {
                        anchors.centerIn: parent
                        rotation: 270
                    }
                }

                // ======= System tray =======
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 5
                    Layout.preferredHeight: 120
                    color: Theme.primaryContainer
                    radius: 8
                    Text {
                        anchors.centerIn: parent
                        rotation: 270
                        text: "systray"
                        color: Theme.oNPrimaryContainer
                    } 
                }

                // ======= Clock =======
                Rectangle {
                    color: Theme.primaryContainer
                    radius: 8

                    Layout.fillWidth: true
                    Layout.margins: 5
                    Layout.preferredHeight: 60
                    ClockWidget {
                        anchors.centerIn: parent
                    }
                }
                
                // ======= Hardware =======
                Rectangle {
                    color: Theme.primaryContainer
                    radius: 8
                    Layout .fillWidth: true
                    Layout.margins: 5
                    Layout.preferredHeight: 160

                    System {
                        anchors.fill: parent
                    }
                }
            }
        }
    }
}