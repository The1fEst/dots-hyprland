pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common.models
import qs.modules.common.widgets
import qs.modules.macos.looks

Item {
    id: root

    required property var entry
    property bool selected: false

    readonly property string rawValue: root.entry?.rawValue ?? ""
    readonly property bool isImage: root.rawValue.length > 0 && Cliphist.entryIsImage(root.rawValue)
    readonly property var imageSize: root.rawValue.match(/(\d+)x(\d+)/)
    readonly property color foreground: root.selected ? "#ffffff" : Looks.colors.primary

    signal activated
    signal entered

    implicitHeight: root.isImage ? 60 : 44

    Rectangle {
        anchors {
            fill: parent
            leftMargin: 14
            rightMargin: 14
        }
        radius: Looks.radius.normal
        color: root.selected ? Looks.accent : (hoverArea.containsMouse ? Looks.colors.quaternary : "transparent")
        antialiasing: true
    }

    Item {
        id: iconSlot
        anchors {
            left: parent.left
            leftMargin: 26
            verticalCenter: parent.verticalCenter
        }
        width: root.isImage ? 76 : 28
        height: root.isImage ? 44 : 28

        IconImage {
            anchors.fill: parent
            visible: root.entry?.iconType === LauncherSearchResult.IconType.System
            source: Quickshell.iconPath(root.entry?.iconName ?? "", "image-missing")
            smooth: true
        }

        MaterialSymbol {
            anchors.centerIn: parent
            visible: root.entry?.iconType === LauncherSearchResult.IconType.Material
            text: root.entry?.iconName ?? ""
            iconSize: 24
            color: root.foreground
        }

        MText {
            anchors.centerIn: parent
            visible: root.entry?.iconType === LauncherSearchResult.IconType.Text
            text: root.entry?.iconName ?? ""
            font.pixelSize: 22
            color: root.foreground
        }

        MaterialSymbol {
            anchors.centerIn: parent
            visible: root.entry?.iconType === LauncherSearchResult.IconType.None && !root.isImage
            text: root.rawValue.length > 0 ? "content_paste" : "search"
            iconSize: 22
            color: root.selected ? "#ffffff" : Looks.colors.secondary
        }

        Loader {
            anchors.centerIn: parent
            active: root.isImage
            sourceComponent: CliphistImage {
                entry: root.rawValue
                maxWidth: 76
                maxHeight: 44
                color: "transparent"
                radius: Looks.radius.tiny
            }
        }
    }

    MText {
        anchors {
            left: iconSlot.right
            leftMargin: 14
            right: verb.left
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }
        text: root.isImage ? (root.imageSize ? `${root.imageSize[1]} × ${root.imageSize[2]} image` : "Image") : (root.entry?.name ?? "")
        font.pixelSize: Looks.font.size.medium
        font.family: !root.isImage && root.entry?.fontType === LauncherSearchResult.FontType.Monospace ? Looks.font.mono : Looks.font.text
        color: root.foreground
        elide: Text.ElideRight
    }

    MText {
        id: verb
        anchors {
            right: parent.right
            rightMargin: 28
            verticalCenter: parent.verticalCenter
        }
        visible: root.selected && text.length > 0
        text: root.entry?.verb ?? ""
        font.pixelSize: Looks.font.size.small
        color: "#b3ffffff"
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.entered()
        onClicked: root.activated()
    }
}
