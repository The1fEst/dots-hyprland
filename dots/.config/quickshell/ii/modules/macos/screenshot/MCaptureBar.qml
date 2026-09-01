pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.common.widgets
import qs.modules.macos.looks

Item {
    id: root

    property int action: 0
    property bool windowMode: false
    property bool pointer: false

    signal chosen(int action)
    signal modeChosen(bool windowMode)
    signal pointerToggled
    signal dismissed

    readonly property list<var> modes: [
        {
            action: 0,
            icon: "photo_camera"
        },
        {
            action: 1,
            icon: "draw"
        },
        {
            action: 2,
            icon: "videocam"
        },
        {
            action: 3,
            icon: "video_camera_front"
        }
    ]

    implicitWidth: row.implicitWidth + 20
    implicitHeight: 52

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Looks.colors.materialUltrathick
        antialiasing: true
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4

        BarButton {
            icon: "crop_free"
            active: !root.windowMode
            onActivated: root.modeChosen(false)
        }

        BarButton {
            icon: "web_asset"
            active: root.windowMode
            onActivated: root.modeChosen(true)
        }

        Divider {}

        Repeater {
            model: root.modes

            BarButton {
                required property var modelData

                icon: modelData.icon
                active: root.action === modelData.action
                onActivated: root.chosen(modelData.action)
            }
        }

        Divider {}

        BarButton {
            icon: "mouse"
            active: root.pointer
            onActivated: root.pointerToggled()
        }

        Divider {}

        BarButton {
            icon: "close"
            onActivated: root.dismissed()
        }
    }

    component Divider: Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 24
        color: Looks.colors.divider
    }

    component BarButton: Rectangle {
        id: button

        property string icon: ""
        property bool active: false

        signal activated

        width: 40
        height: 36
        radius: Looks.radius.normal
        antialiasing: true
        color: button.active ? Looks.colors.tertiary : (hoverArea.containsMouse ? Looks.colors.quaternary : "transparent")

        MaterialSymbol {
            anchors.centerIn: parent
            text: button.icon
            iconSize: 21
            color: Looks.colors.primary
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.ArrowCursor
            onClicked: button.activated()
        }
    }
}
