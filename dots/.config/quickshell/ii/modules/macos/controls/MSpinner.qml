pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Item {
    id: root

    property bool running: false
    property int spokes: 8
    property real size: 16

    implicitWidth: root.size
    implicitHeight: root.size

    visible: root.running
    opacity: root.running ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: Looks.animation.fast
        }
    }

    Item {
        id: wheel
        anchors.fill: parent

        Repeater {
            model: root.spokes

            Rectangle {
                required property int index

                x: (root.size - width) / 2
                y: 0
                width: Math.max(1, root.size * 0.11)
                height: root.size * 0.3
                radius: width / 2
                antialiasing: true
                color: Looks.colors.secondary
                opacity: 1 - index / root.spokes
                transform: Rotation {
                    origin.x: width / 2
                    origin.y: root.size / 2
                    angle: index * 360 / root.spokes
                }
            }
        }

        RotationAnimator {
            target: wheel
            running: root.running
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
        }
    }
}
