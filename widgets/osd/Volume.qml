import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

Scope {
    id: root

    // Bind the pipewire node so its volume will be tracked
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            root.shouldShowOsd = true;
            hideTimer.restart();
        }

        // Nueva conexión para detectar cuando se silencia/desilencia el sink
        function onMutedChanged() {
            root.shouldShowOsd = true;
            hideTimer.restart();
        }
    }

    property bool shouldShowOsd: false

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    // The OSD window will be created and destroyed based on shouldShowOsd.
    // PanelWindow.visible could be set instead of using a loader, but using
    // a loader will reduce the memory overhead when the window isn't open.
    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            // Since the panel's screen is unset, it will be picked by the compositor
            // when the window is created. Most compositors pick the current active monitor.

            anchors.bottom: true
            margins.bottom: screen.height / 5
            exclusiveZone: 0

            implicitWidth: 400
            implicitHeight: 50
            color: "transparent"

            // An empty click mask prevents the window from blocking mouse events.
            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: "#80000000"

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 15
                    }

                    IconImage {
                        implicitSize: 30
                        // Evaluamos si está silenciado para cambiar el ícono dinámicamente
                        source: (Pipewire.defaultAudioSink?.audio.muted ?? false)
                            ? Quickshell.iconPath("audio-volume-muted-symbolic")
                            : Quickshell.iconPath("audio-volume-high-symbolic")
                    }

                    Rectangle {
                        // Stretches to fill all left-over space
                        Layout.fillWidth: true

                        implicitHeight: 10
                        radius: 20
                        color: "#50ffffff"

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            // Si lo deseas, puedes hacer que la barra baje a 0 cuando está silenciado 
                            // multiplicando por un ternario, pero lo estándar es mantener el nivel 
                            // visual y solo cambiar el ícono.
                            implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
                            radius: parent.radius
                            
                            // Opcional: Cambiar el color de la barra si está silenciado para darle más énfasis
                            color: (Pipewire.defaultAudioSink?.audio.muted ?? false) ? "#80ffffff" : "#ffffff"
                        }
                    }
                }
            }
        }
    }
}