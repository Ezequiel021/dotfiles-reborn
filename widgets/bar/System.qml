import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower
import Quickshell
import qs.theme
import qs.tokens
import qs.templates

import qs.widgets.bar.system

Item {
    id: systemTrayRoot
    height: 30
    anchors {
        fill: parent
    }

    Rectangle {
        id: bgRect
        color: Theme.primary_container

        anchors {
            fill: parent
            margins: Tokens.containerMargins
        }

        radius: 20
    }

    ColumnLayout {
        id: trayLayout
        spacing: 10
        anchors.fill: parent

        // Spacer superior para empujar todo hacia el centro
        Item {
            Layout.fillHeight: true
        }

        Item {
            id: network
            Layout.preferredHeight: 24
            Layout.fillWidth: true
            property bool ethernet: {
                return Networking.devices.values.filter(dev => dev.state === ConnectionState.Connected && dev.type === DeviceType.Wired).size > 0;
            }
            property var active_wifi_device: {
                var nw = Networking.devices.values.filter(dev => dev.state === ConnectionState.Connected && dev.type === DeviceType.Wifi)[0];
                console.log(nw.name);
                return nw;
            }
            property WifiNetwork active_wifi: {
                return active_wifi_device.networks.values[0];
            }
            MaterialIcon {
                anchors.centerIn: parent
                source: {
                    if (network.ethernet) {
                        return "cable";
                    } else {
                        if (network.active_wifi_device.state === ConnectionState.Connected) {
                            if (network.active_wifi.signalStrength > 0.9)
                                return "signal_wifi_4_bar";
                            if (network.active_wifi.signalStrength > 0.5)
                                return "network_wifi_3_bar";
                            if (network.active_wifi.signalStrength > 0.3)
                                return "network_wifi_2_bar";
                            if (network.active_wifi.signalStrength > 0.1)
                                return "network_wifi_1_bar";
                            else
                                return "signal_wifi_0_bar";
                        } else
                            return "signal_wifi_bad";
                    }
                }
                color: Theme.on_primary_container
            }
        }

        // --- Widget de Bluetooth ---
        Item {
            id: bluetooth
            Layout.preferredHeight: 24
            Layout.fillWidth: true
            property var connectedDevices: Bluetooth.defaultAdapter.devices.values.filter(device => device.connected === true)
            property bool connected: {
                return connectedDevices.length > 0;
            }
            MaterialIcon {
                anchors.centerIn: parent
                source: bluetooth.connected ? "bluetooth_connected" : "bluetooth"
                size: 24
                color: Theme.on_primary_container
            }
        }

        Item {
            id: battery
            Layout.preferredHeight: 24
            Layout.fillWidth: true
            property var percentage: {
                return Math.round(UPower.displayDevice.percentage * 100);
            }
            MaterialIcon {
                id: icon
                size: 24
                source: {
                    if (battery.percentage > 95)
                        return "battery_full";
                    else if (UPower.displayDevice.state === UPowerDeviceState.Charging) {
                        if (battery.percentage > 90)
                            return "battery_charging_90";
                        if (battery.percentage > 80)
                            return "battery_charging_80";
                        if (battery.percentage > 60)
                            return "battery_charging_60";
                        if (battery.percentage > 50)
                            return "battery_charging_50";
                        if (battery.percentage > 30)
                            return "battery_charging_30";
                        if (battery.percentage > 20)
                            return "battery_charging_20";
                        return "battery_charging_full";
                    } else {
                        if (battery.percentage >= 90)
                            return "battery_6_bar";
                        if (battery.percentage >= 80)
                            return "battery_5_bar";
                        if (battery.percentage >= 60)
                            return "battery_4_bar";
                        if (battery.percentage >= 50)
                            return "battery_3_bar";
                        if (battery.percentage >= 30)
                            return "battery_2_bar";
                        if (battery.percentage >= 20)
                            return "battery_1_bar";
                        return "battery_alert";
                    }
                }
                color: Theme.on_primary_container
                anchors.centerIn: parent
            }
        }

        AnimatedPopup {
            id: popup
            popupWidth: Tokens.trayMenuWidth
            popupHeight: 400

            isOpen: false
            anchorItem: systemTrayRoot
            contentComponent: Rectangle {
                anchors.fill: parent
                color: "white"
                LazyLoader {
                    activeAsync: popup.isOpen
                    Battery {}
                }
            }
        }

        // Spacer inferior
        Item {
            Layout.fillHeight: true
        }
    }
}
