pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Rectangle {
    id: root

    property int controlHeight: Looks.control.small
    property bool checked: false
    property bool available: true

    readonly property var metrics: Looks.control.switchMetrics(root.controlHeight)
    readonly property real knobInset: (root.controlHeight - root.metrics.knobHeight) / 2

    signal toggled(bool checked)

    implicitWidth: root.metrics.width
    implicitHeight: root.controlHeight
    radius: height / 2
    antialiasing: true
    enabled: root.available
    opacity: root.available ? 1 : 0.4
    color: {
        if (root.checked)
            return press.pressed ? Looks.accentPressed : Looks.accent;
        return press.pressed ? Looks.colors.pressed : Looks.colors.quaternary;
    }

    Behavior on color {
        ColorAnimation {
            duration: Looks.animation.fast
        }
    }

    Rectangle {
        x: root.checked ? root.width - width - root.knobInset : root.knobInset
        anchors.verticalCenter: parent.verticalCenter
        width: root.metrics.knobWidth
        height: root.metrics.knobHeight
        radius: height / 2
        color: Looks.colors.switchKnob
        antialiasing: true

        Behavior on x {
            NumberAnimation {
                duration: Looks.animation.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Looks.animation.standard
            }
        }
    }

    MouseArea {
        id: press
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
