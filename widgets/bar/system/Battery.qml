import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import qs.theme
import qs.tokens
import qs.templates
import Quickshell.Services.UPower

Item {
    Process {
        property string profile: "hewwo"
        id: tlpstatus
        command: ["tlpctl", "get"]
        stdout: SplitParser {
            onRead: (token) => {
                tlpstatus.profile = token;
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        onTriggered: {
            tlpstatus.running = true;
        }
    }
    id: root
    anchors.fill: parent
    anchors.margins: Tokens.containerMargins
    ColumnLayout {
        anchors.fill: parent
        Item {
            Layout.fillHeight: true
        }

        RowLayout {
            Text { text: "Battery" }
            Item {Layout.fillWidth: true}
            Text {text: tlpstatus.profile}
        }

        Rectangle {
            id: batteryBg // Le damos un ID al fondo
            radius: 12
            color: Theme.surface_container_high
            Layout.preferredHeight: 40
            Layout.fillWidth: true

            // 1. Un contenedor que define HASTA DÓNDE se ve la batería (recorte recto)
            Item {
                height: parent.height
                width: batteryBg.width * UPower.displayDevice.percentage
                clip: true // Hace un recorte cuadrado perfecto

                // 2. El color de la batería, que tiene el mismo tamaño y curva que el fondo
                Rectangle {
                    color: Theme.primary
                    height: batteryBg.height
                    width: batteryBg.width   // IMPORTANTE: Mide lo mismo que el fondo
                    radius: batteryBg.radius // IMPORTANTE: Tiene el mismo radio
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                Item {
                    Layout.fillWidth: true
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: battery.width
                    color: Theme.primary_container
                    radius: height / 2

                    RowLayout {
                        id: battery
                        Item {
                            Layout.fillWidth: true
                        }
                        MaterialIcon {
                            color: Theme.on_primary_container
                            source: {
                                if (UPower.displayDevice.percentage <= 0.15) return "battery_alert";
                                if (UPower.displayDevice.state === UPowerDeviceState.Charging) return "bolt";
                            }
                        }
                        Text {
                            text: UPower.displayDevice.percentage * 100
                            color: Theme.on_primary_container
                            font.weight: 700
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}
