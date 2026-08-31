pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.services
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    readonly property var player: MprisController.activePlayer


    ClippingRectangle {
        id: art
        anchors {
            left: parent.left
            top: parent.top
            margins: 14
        }
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
        anchors {
            left: parent.left
            right: parent.right
            top: art.bottom
            margins: 14
            topMargin: 8
        }
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
            enabled: MprisController.canGoPrevious
            onActivated: root.player?.previous()
        }

        Control {
            text: MprisController.isPlaying ? "pause" : "play_arrow"
            enabled: MprisController.canTogglePlaying
            onActivated: root.player?.togglePlaying()
        }

        Control {
            text: "skip_next"
            enabled: MprisController.canGoNext
            onActivated: root.player?.next()
        }
    }
}
