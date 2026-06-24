import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.widgets.control
import Quickshell.Hyprland

Scope {
    id: root

    IpcHandler {
        target: "control-panel"

        function toggle() {
            root.shouldShow = !root.shouldShow
        }
    }

    property bool shouldShow: false
    property string globalTemp: "--°C"
    property string globalWeatherIcon: "🌤️"

    Timer {
        interval: 900000 // 15 minutos
        running: true
        repeat: true
        triggeredOnStart: true // Corre de inmediato al arrancar Quickshell
        onTriggered: fetchGlobalWeather()
    }

    function fetchGlobalWeather() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://wttr.in/?format=j1")
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText)
                var current = response.current_condition[0]

                root.globalTemp = current.temp_C + "°C"

                var desc = current.weatherDesc[0].value.toLowerCase()
                if (desc.includes("sunny") || desc.includes("clear")) root.globalWeatherIcon = "☀️"
                else if (desc.includes("cloud")) root.globalWeatherIcon = "☁️"
                else if (desc.includes("rain") || desc.includes("shower")) root.globalWeatherIcon = "🌧️"
                else if (desc.includes("snow")) root.globalWeatherIcon = "❄️"
                else if (desc.includes("thunder")) root.globalWeatherIcon = "⛈️"
                else root.globalWeatherIcon = "🌤️"

                console.log("Clima actualizado en segundo plano:", root.globalTemp)
            }
        }
        xhr.send()
    }

    PanelWindow {
        visible: root.shouldShow
        id: window
        anchors.bottom: true
        margins.bottom: (1080 - 800) / 2
        exclusiveZone: 0

        implicitWidth: 1400
        implicitHeight: 800
        color: "transparent"

        focusable: true

        HyprlandFocusGrab {
            id: grab
            windows: [window]
            active: root.shouldShow
            onCleared: {
                root.shouldShow = false
            }
        }

        Shortcut {
            sequence: "Escape"
            enabled: root.shouldShow
            onActivated: {
                root.shouldShow = false
            }
        }

        Rectangle {
            id: panelContent
            anchors.fill: parent
            radius: 30
            color: '#24262c'

            RowLayout {
                anchors {
                    fill: parent
                    margins: 30
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    radius: 24

                    AppGrid {
                        anchors.fill: parent
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        ClockWeather {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            temp: root.globalTemp
                            weatherIcon: root.globalWeatherIcon
                        }

                        Media {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    color: "#90ffffff"
                    Text {
                        color: "white"
                        anchors.centerIn: parent
                        text: "3"
                    }
                }
            }
        }
    }
}
