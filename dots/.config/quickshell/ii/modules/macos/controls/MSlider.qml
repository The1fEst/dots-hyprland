pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import qs.modules.macos.looks

Item {
    id: root

    property real value: 0
    property real trackWidth: 200

    signal moved(real value)

    readonly property int trackHeight: 6
    readonly property int knobWidth: 20
    readonly property int knobHeight: 16

    readonly property real trackInset: root.knobWidth / 2

    implicitWidth: root.trackWidth
    implicitHeight: root.knobHeight

    Rectangle {
        id: track
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: root.trackInset
            rightMargin: root.trackInset
            verticalCenter: parent.verticalCenter
        }
        height: root.trackHeight
        radius: height / 2
        color: Looks.colors.quaternary
        antialiasing: true

        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: Math.max(0, Math.min(1, root.value)) * track.width
            radius: parent.radius
            color: Looks.accent
            antialiasing: true
        }
    }

    Rectangle {
        id: knob

        x: Math.round(Math.max(0, Math.min(1, root.value)) * track.width + root.trackInset - width / 2)
        anchors.verticalCenter: parent.verticalCenter
        width: root.knobWidth
        height: root.knobHeight
        radius: height / 2
        color: Looks.dark ? "#dedede" : "#ffffff"
        antialiasing: true

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#1f000000"
            shadowVerticalOffset: 1
            blurMax: 6
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: event => root.moved(Math.max(0, Math.min(1, (event.x - root.trackInset) / track.width)))
        onPressed: event => root.moved(Math.max(0, Math.min(1, (event.x - root.trackInset) / track.width)))
    }
}
