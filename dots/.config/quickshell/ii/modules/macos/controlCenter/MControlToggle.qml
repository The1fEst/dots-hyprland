pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    required property QtObject toggleModel
    property bool wide: false
    property string settingsCommand: ""

    readonly property bool lit: toggleModel.toggled
    readonly property color activeColor: lit ? Looks.accent : Looks.colors.quaternary

    tint: !wide && lit ? Looks.accent : Looks.glass.tint
    radius: wide ? Math.min(Looks.radius.toggleWide, height / 2) : Math.min(width, height) / 2
    opacity: toggleModel.available ? 1 : 0.4

    Rectangle {
        id: badge
        visible: root.wide
        anchors {
            left: parent.left
            leftMargin: 14
            verticalCenter: parent.verticalCenter
        }
        width: 32
        height: 32
        radius: width / 2
        color: root.activeColor
        antialiasing: true
    }

    MaterialSymbol {
        anchors.centerIn: root.wide ? badge : parent
        text: root.toggleModel.icon
        iconSize: root.wide ? 18 : 22
        color: root.wide ? (root.lit ? "#ffffff" : Looks.colors.primary) : (root.lit ? "#ffffff" : Looks.colors.primary)
    }

    MaterialSymbol {
        id: chevron
        visible: root.wide && root.settingsCommand.length > 0
        anchors {
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
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

    Column {
        visible: root.wide
        anchors {
            left: badge.right
            leftMargin: 12
            right: chevron.visible ? chevron.left : parent.right
            rightMargin: 0
            verticalCenter: parent.verticalCenter
        }
        spacing: 1

        MText {
            width: parent.width
            text: root.toggleModel.name
            emphasized: true
            elide: Text.ElideRight
            font.pixelSize: Looks.font.size.normal
            color: Looks.colors.primary
        }

        MText {
            width: parent.width
            visible: root.toggleModel.hasStatusText && text.length > 0
            text: root.toggleModel.statusText
            elide: Text.ElideRight
            font.pixelSize: Looks.font.size.normal
            color: Looks.colors.secondary
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.toggleModel.available
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton && root.toggleModel.altAction)
                root.toggleModel.altAction();
            else if (root.wide && root.settingsCommand.length > 0)
                Quickshell.execDetached(["bash", "-c", root.settingsCommand]);
            else
                root.toggleModel.mainAction();
        }
    }

    MouseArea {
        anchors.fill: badge
        anchors.margins: -4
        visible: root.wide
        enabled: root.toggleModel.available
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleModel.mainAction()
    }
}
