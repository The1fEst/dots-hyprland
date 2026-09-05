pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.controls
import qs.modules.macos.looks

Rectangle {
    id: root

    required property string label
    required property string icon
    required property color tint
    required property bool current

    signal clicked

    implicitWidth: parent?.width ?? 0
    implicitHeight: Looks.settings.sidebarRowHeight
    radius: Looks.settings.sidebarSelectionRadius
    antialiasing: true
    color: root.current ? Looks.accent : "transparent"

    MIconBadge {
        id: badge
        anchors {
            left: parent.left
            leftMargin: Looks.settings.sidebarRowInset
            verticalCenter: parent.verticalCenter
        }
        tint: root.tint
        symbol: root.icon
        badgeSize: Looks.settings.sidebarIconSlot
        badgeRadius: Looks.settings.sidebarIconRadius
        glyphWidth: 16
        glyphHeight: 14
    }

    MText {
        anchors {
            left: badge.right
            leftMargin: Looks.settings.sidebarIconGap
            right: parent.right
            rightMargin: Looks.settings.sidebarIconGap
            verticalCenter: parent.verticalCenter
        }
        text: root.label
        elide: Text.ElideRight
        color: root.current ? "#ffffff" : Looks.colors.primary
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
