pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Rectangle {
    id: root

    property int controlHeight: Looks.control.regular
    property string symbol: ""
    property real symbolSize: root.controlHeight * 0.5

    signal clicked

    implicitWidth: root.controlHeight
    implicitHeight: root.controlHeight
    radius: height / 2
    antialiasing: true
    color: press.pressed ? Looks.surfaces.buttonBorderedPressed : Looks.surfaces.buttonBordered

    MSymbol {
        anchors.centerIn: parent
        symbol: root.symbol
        symbolSize: root.symbolSize
        color: Looks.colors.primary
    }

    MouseArea {
        id: press
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
