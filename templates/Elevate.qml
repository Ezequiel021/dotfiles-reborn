import QtQuick

Item {
    id: root
    default property Item contentComponent
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onHoveredChanged: {
            area.containsMouse ? root.contentComponent.scale = 1.1 : root.contentComponent.scale = 1.0;
        }
    }
    // Behavior on contentComponent.scale {

    // }
}
