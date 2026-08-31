pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.services
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    readonly property var player: MprisController.currentPlayer

    readonly property bool compact: root.width < 100
    readonly property bool tall: root.height > 100

    signal activated

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    ClippingRectangle {
        id: art
        x: root.compact ? (root.width - width) / 2 : 14
        y: root.tall ? 14 : (root.height - height) / 2
        width: 38
        height: 38
        radius: 8
        color: Looks.colors.quaternary
        antialiasing: true

        Image {
            anchors.fill: parent
            source: root.player?.trackArtUrl ?? ""
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
        }

        MaterialSymbol {
            anchors.centerIn: parent
            visible: !root.player
            text: "music_note"
            iconSize: 20
            color: Looks.colors.secondary
        }
    }

    Column {
        id: info
        visible: !root.compact
        x: root.tall ? 14 : art.x + art.width + 12
        y: root.tall ? art.y + art.height + 8 : (root.height - implicitHeight) / 2
        width: root.width - x - 14
        spacing: 1

        MText {
            width: parent.width
            text: root.player?.trackTitle ?? "Not Playing"
            emphasized: true
            elide: Text.ElideRight
            font.pixelSize: Looks.font.size.normal
            color: Looks.colors.primary
        }

        MText {
            width: parent.width
            text: root.player?.trackArtist ?? ""
            elide: Text.ElideRight
            font.pixelSize: Looks.font.size.normal
            color: Looks.colors.secondary
        }
    }

    Row {
        visible: root.tall
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 12
        }
        spacing: 16

        component Control: MaterialSymbol {
            iconSize: 22
            color: enabled ? Looks.colors.primary : Looks.colors.tertiary

            property bool enabled: true
            signal activated

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                enabled: parent.enabled
                cursorShape: Qt.PointingHandCursor
                onClicked: parent.activated()
            }
        }

        Control {
            text: "skip_previous"
            enabled: root.player?.canGoPrevious ?? false
            onActivated: root.player?.previous()
        }

        Control {
            text: root.player?.isPlaying ? "pause" : "play_arrow"
            enabled: root.player?.canTogglePlaying ?? false
            onActivated: root.player?.togglePlaying()
        }

        Control {
            text: "skip_next"
            enabled: root.player?.canGoNext ?? false
            onActivated: root.player?.next()
        }
    }
}
