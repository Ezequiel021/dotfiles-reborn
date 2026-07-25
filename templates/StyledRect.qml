import QtQuick
import qs.tokens

Rectangle {
    Behavior on color {
        ColorAnimation {
            duration: Tokens.expressiveAnimDuration
            easing: Tokens.expressiveAnimEasing
        }
    }
}