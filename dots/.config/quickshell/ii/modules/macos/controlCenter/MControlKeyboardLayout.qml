pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    readonly property string code: HyprlandXkb.currentLayoutCode.toUpperCase()

    Row {
        anchors.centerIn: parent
        spacing: 8

        MaterialSymbol {
            anchors.verticalCenter: parent.verticalCenter
            text: "language"
            iconSize: 22
            color: Looks.colors.primary
        }

        MText {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.code.length > 0
            text: root.code
            font.pixelSize: Looks.font.size.large
            emphasized: true
            color: Looks.colors.primary
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"])
    }
}
