import QtQuick
import qs.theme
Item {
    Rectangle {
        anchors.fill: parent
        anchors.margins: 5
        color: "transparent"
        radius: 20
    }

    Text {
        anchors.centerIn: parent
        color: Theme.on_surface
        font {
            family: "JetBrains Mono Nerd Font"
            bold: true
            pixelSize: 18
        }
        text: Time.time
    }
}