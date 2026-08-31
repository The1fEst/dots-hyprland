pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    property string label: ""
    property string settingsCommand: ""
    property string leadingIcon: ""
    property string trailingIcon: ""
    property real value: 0
    property real minimum: 0
    property real maximum: 1

    signal moved(real newValue)

    readonly property bool compact: root.width < root.height * 1.6
    readonly property real inset: root.width > 200 ? 20 : 14

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.settingsCommand.length > 0
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["bash", "-c", root.settingsCommand])
    }

    MaterialSymbol {
        id: chevron
        visible: root.settingsCommand.length > 0 && !root.compact
        anchors {
            right: parent.right
            rightMargin: root.inset
            verticalCenter: caption.verticalCenter
        }
        text: "chevron_right"
        iconSize: 18
        color: Looks.colors.secondary
        opacity: hoverArea.containsMouse ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }
    }

    MText {
        id: caption
        visible: !root.compact
        anchors {
            left: parent.left
            leftMargin: root.inset
            top: parent.top
            topMargin: 10
        }
        text: root.label
        emphasized: true
        color: Looks.colors.primary
    }

    MaterialSymbol {
        id: leading
        x: root.compact ? (root.width - width) / 2 : root.inset
        y: root.compact ? (root.height - height) / 2 : root.height - height - 12
        text: root.leadingIcon
        iconSize: root.compact ? 22 : 18
        color: root.compact ? Looks.colors.primary : Looks.colors.secondary
    }

    MaterialSymbol {
        id: trailing
        visible: !root.compact
        anchors {
            right: parent.right
            rightMargin: root.inset
            bottom: parent.bottom
            bottomMargin: 12
        }
        text: root.trailingIcon
        iconSize: 18
        color: Looks.colors.secondary
    }

    Item {
        id: track
        visible: !root.compact
        anchors {
            left: leading.right
            leftMargin: 10
            right: trailing.left
            rightMargin: 10
            verticalCenter: leading.verticalCenter
        }
        height: 6

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Looks.colors.quaternary
        }

        Rectangle {
            id: fill
            width: parent.width * Math.max(0, Math.min(1, (root.value - root.minimum) / Math.max(0.0001, root.maximum - root.minimum)))
            height: parent.height
            radius: height / 2
            color: Looks.colors.primary
        }

        Rectangle {
            width: 22
            height: 14
            radius: height / 2
            color: Looks.colors.primary
            antialiasing: true
            x: Math.max(0, Math.min(track.width - width, fill.width - width / 2))
            anchors.verticalCenter: parent.verticalCenter
            opacity: hoverArea.containsMouse ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -10
            cursorShape: Qt.PointingHandCursor

            function apply(x) {
                const fraction = Math.max(0, Math.min(1, x / track.width));
                root.moved(root.minimum + fraction * (root.maximum - root.minimum));
            }

            onPressed: event => apply(event.x)
            onPositionChanged: event => {
                if (pressed)
                    apply(event.x);
            }
        }
    }
}
