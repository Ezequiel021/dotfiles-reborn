import QtQuick
Text {
    // property real fill
    // property int grade: Colours.light ? 0 : -25
    // property font fontStyle: Tokens.font.icon.small

    // font: Tokens.font.icon.size(fontStyle.pointSize).weight(fontStyle.weight).vaxes(fontStyle.variableAxes).fill(fill.toFixed(1)).grade(grade).build()
    required property string source
    property int size: 20
    font {
        family: "Material Symbols Rounded"
        weight: 500
        pixelSize: size
    }

    text: source
}
