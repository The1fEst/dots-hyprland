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

        MSymbol {
            anchors.verticalCenter: parent.verticalCenter
            symbol: MSymbols.language
            height: Looks.control.glyph.tile
            color: Looks.colors.primary
        }

        MText {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.code.length > 0
            text: root.code
            font.pixelSize: Looks.font.style.title3.size
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
