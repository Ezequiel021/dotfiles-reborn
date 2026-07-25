import QtQuick
import QtQuick.Controls
import qs.theme

Item {
    id: root
    implicitWidth: 25
    implicitHeight: 25

    property string iconSource: ""
    property string tooltipText: ""
    property color iconColor: Theme.text 
    property alias isHovered: hoverArea.hovered
    
    HoverHandler {
        id: hoverArea
    }

    Behavior on iconColor {
        ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
    }

    Button {
        anchors.centerIn: parent
        anchors.fill: parent

        background: Rectangle {
            color: "transparent"
        }

        icon {
            source: root.iconSource
            color: root.iconColor
            width: 25
            height: 25
        }

        hoverEnabled: true
        onHoveredChanged: {
            hovered: hoverArea.hovered
        }
    }
}