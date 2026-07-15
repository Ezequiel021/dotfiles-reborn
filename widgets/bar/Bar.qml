import Quickshell
import QtQuick
import QtQuick.Layouts

// qmllint disable uncreatable-type
Scope {
    Variants {
        model: Quickshell.screens;

        PanelWindow {
            required property var modelData
            screen: modelData

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

                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 5
                    Layout.preferredHeight: 300
                    color: "red"
                    radius: 8
                    Tags {
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 5
                    Layout.fillHeight: true
                    color: "red"
                    radius: 8
                    Title {
                        anchors.centerIn: parent
                        rotation: 270
                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 5
                    Layout.preferredHeight: 120
                    color: "red"
                    radius: 8
                    Text {
                        anchors.centerIn: parent
                        rotation: 270
                        text: "systray"
                    } 
                }

                Rectangle {
                    color: "red"
                    radius: 8

                    Layout.fillWidth: true
                    Layout.margins: 5
                    Layout.preferredHeight: 60
                    ClockWidget {
                        anchors.centerIn: parent
                    }
                }
                
                Rectangle {
                    color: "red"
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