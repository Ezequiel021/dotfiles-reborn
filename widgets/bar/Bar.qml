import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.theme

// qmllint disable uncreatable-type
Scope {
    Variants {
        model: Quickshell.screens;

        PanelWindow {
            id: panelWindow
            required property var modelData
            screen: modelData

            color: Theme.background
            
            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: 56

            ColumnLayout {
                anchors {
                    fill: parent
                }

                // ======= Tags =======
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180

                    /* Workspaces {
                        anchors.fill: parent
                        currentMonitor: panelWindow.modelData
                    } */
                    WorkspacesV2 {
                        anchors.fill: parent
                        currentMonitor: panelWindow.modelData
                    }
                }

                // ======= Title =======
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Title {
                        anchors.fill: parent
                    }
                }

                // ======= System tray =======
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80

                    Tray {
                        anchors.fill: parent
                    }
                }

                // ======= Clock =======
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    ClockWidget {
                        anchors.fill: parent
                    }
                }
                
                // ======= Hardware =======
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200

                    System {
                        anchors.fill: parent
                    }
                }
            }
        }
    }
}