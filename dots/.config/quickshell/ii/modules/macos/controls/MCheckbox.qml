pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Item {
    id: root

    property string label: ""
    property bool checked: false
    property bool emphasized: false

    signal toggled(bool checked)

    readonly property int boxSize: Looks.control.boxSize

    implicitHeight: Looks.control.regular
    implicitWidth: root.boxSize + (root.label.length > 0 ? Looks.control.boxLabelGap + text.implicitWidth : 0)

    Rectangle {
        id: box
        y: Math.round((root.height - height) / 2)
        width: root.boxSize
        height: root.boxSize
        radius: Looks.controlRadius(root.boxSize)
        antialiasing: true
        color: {
            if (root.checked)
                return press.pressed ? Looks.accentPressed : Looks.accent;
            return press.pressed ? Looks.colors.pressed : Looks.colors.quaternary;
        }

        MSymbol {
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)
            visible: root.checked
            symbol: "checkmark"
            height: Looks.control.boxTick
            color: "#ffffff"
        }
    }

    MText {
        id: text
        anchors.verticalCenter: parent.verticalCenter
        x: box.width + Looks.control.boxLabelGap
        visible: root.label.length > 0
        text: root.label
        emphasized: root.emphasized
        color: Looks.colors.primary
    }

    MouseArea {
        id: press
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
