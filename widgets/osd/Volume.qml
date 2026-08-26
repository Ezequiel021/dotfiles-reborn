import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.templates
import qs.theme

Scope {
    id: root
    // Bind the pipewire node so its volume will be tracked
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
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

    OverlayPanel {
        isOpen: root.shouldShowOsd
        edge: "top"
        panelWidth: 300
        panelHeight: 50

        Rectangle {
            anchors.fill: parent
            color: Theme.surface
            bottomLeftRadius: 22
            bottomRightRadius: bottomLeftRadius

            FilledSlider {
                anchors.fill: parent
                anchors.margins: 12
                anchors.topMargin: 8
                icon: "volume_up"

                value: 100 * (Pipewire.defaultAudioSink?.audio.volume?? 0)
            }
        }
    }
}
