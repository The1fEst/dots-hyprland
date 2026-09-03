pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Rectangle {
    id: root

    property int controlHeight: Looks.control.regular
    property string label: ""
    property real minimumWidth: 0

    signal clicked

    implicitWidth: Math.max(text.implicitWidth + Looks.control.buttonLabelInset * 2, root.implicitHeight, root.minimumWidth)
    implicitHeight: root.controlHeight
    radius: Looks.controlRadius(root.implicitHeight)
    antialiasing: true
    color: press.pressed ? Looks.surfaces.buttonBorderedPressed : Looks.surfaces.buttonBordered

    MText {
        id: text
        anchors.centerIn: parent
        text: root.label
        font.styleName: Looks.font.rendered(Looks.font.controlStyleName)
    }

    MouseArea {
        id: press
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
