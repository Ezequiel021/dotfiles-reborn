pragma Singleton
import QtQuick

QtObject {
    readonly property int trayMenuWidth: 280
    readonly property int containerMargins: 8
    readonly property int popupAnimationDuration: 200

    readonly property int expressiveAnimDuration: 150
    readonly property easingCurve expressiveAnimEasing: Easing.OutQuad

    readonly property int fullRadius: 16
    readonly property int halfRadius: 8
}