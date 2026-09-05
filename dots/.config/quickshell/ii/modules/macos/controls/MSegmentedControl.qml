pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Rectangle {
    id: root

    property list<string> segments: []
    property int current: 0

    signal selected(int index)

    implicitHeight: Looks.control.regular
    radius: Looks.controlRadius(root.implicitHeight)
    color: Looks.colors.quinary
    antialiasing: true

    Row {
        anchors.fill: parent

        Repeater {
            model: root.segments

            Item {
                id: segment

                required property string modelData
                required property int index

                readonly property bool chosen: segment.index === root.current

                width: root.width / Math.max(1, root.segments.length)
                height: root.height

                Rectangle {
                    anchors.fill: parent
                    visible: segment.chosen
                    radius: root.radius
                    color: Looks.accent
                    antialiasing: true
                }

                Rectangle {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    visible: !segment.chosen && segment.index < root.segments.length - 1 && segment.index + 1 !== root.current
                    width: 1
                    height: Math.round(parent.height * 0.55)
                    color: Looks.colors.segmentSeparator
                }

                MText {
                    anchors.centerIn: parent
                    text: segment.modelData
                    emphasized: segment.chosen
                    color: segment.chosen ? "#ffffff" : Looks.colors.primary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selected(segment.index)
                }
            }
        }
    }
}
