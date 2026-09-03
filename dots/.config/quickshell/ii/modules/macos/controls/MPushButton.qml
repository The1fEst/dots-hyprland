pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Rectangle {
    id: root

    property int controlHeight: Looks.control.regular
    property string label: ""
    property real minimumWidth: 0
    property bool prominent: false

    signal clicked

    implicitWidth: Math.max(text.implicitWidth + Looks.control.buttonLabelInset * 2, root.implicitHeight, root.minimumWidth)
    implicitHeight: root.controlHeight
    radius: Looks.controlRadius(root.implicitHeight)
    antialiasing: true
    color: root.prominent ? (press.pressed ? Looks.accentPressed : Looks.accent) : (press.pressed ? Looks.surfaces.buttonBorderedPressed : Looks.surfaces.buttonBordered)

    MText {
        id: text
        anchors.centerIn: parent
        text: root.label
        color: root.prominent ? "#ffffff" : Looks.colors.primary
        font.styleName: Looks.font.rendered(Looks.font.controlStyleName)
    }

    MouseArea {
        id: press
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
