import QtQuick
import "../theme"
Text {
    color: Theme.oNPrimaryContainer
    font {
        family: "JetBrains Mono Nerd Font"
        bold: true
        pixelSize: 18
    }
    text: Time.time
}