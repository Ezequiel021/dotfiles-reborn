import QtQuick.Controls
import QtQuick
import qs.theme

Slider {
    id: root
    handle: Item {
        x: root.visualPosition * (root.availableWidth - width)
        implicitHeight: root.height
        implicitWidth: root.height

        Rectangle {
            anchors.fill: parent
            color: Theme.inverse_surface
            radius: 18
            MaterialIcon {
                anchors.centerIn: parent
                font.pixelSize: 20
                color: Theme.on_primary
                source: "volume_up"
            }
        }
    }

    background: Rectangle {
        color: Theme.surface_container_high
        radius: 18
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            implicitWidth: root.handle.x + height

            radius: 18
            color: Theme.primary
        }
    }

    from: 0
    to: 100
}
