pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Widgets
import qs.services
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    signal closed

    readonly property list<MprisPlayer> players: MprisController.visiblePlayers

    implicitHeight: header.height + playerList.implicitHeight + 30

    component TransportButton: MaterialSymbol {
        property bool enabled: true

        signal activated

        color: enabled ? Looks.colors.primary : Looks.colors.tertiary

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            enabled: parent.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.activated()
        }
    }

    component PlayerBlock: Item {
        id: block

        required property MprisPlayer player

        // Live streams report garbage for both, so anything outside a day is treated as unknown.
        readonly property real length: block.sane(MprisController.trackLength(block.player))
        readonly property real position: block.sane(block.player?.position ?? 0)
        readonly property bool seekable: (block.player?.canSeek ?? false) && block.length > 0

        function sane(value: real): real {
            return value > 0 && value < 86400 ? value : 0;
        }
        readonly property bool active: MprisController.currentPlayer === block.player

        implicitHeight: block.length > 0 ? 136 : 112

        Rectangle {
            anchors.fill: parent
            anchors.margins: -6
            radius: 16
            color: block.active ? Looks.colors.quinary : "transparent"
        }

        ClippingRectangle {
            id: art
            width: 60
            height: 60
            radius: 10
            color: Looks.colors.quaternary
            antialiasing: true

            Image {
                anchors.fill: parent
                source: block.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
            }

            MaterialSymbol {
                anchors.centerIn: parent
                visible: !(block.player?.trackArtUrl ?? "")
                text: "music_note"
                iconSize: 26
                color: Looks.colors.secondary
            }
        }

        Column {
            anchors {
                left: art.right
                right: parent.right
                leftMargin: 12
                verticalCenter: art.verticalCenter
            }
            spacing: 1

            MText {
                width: parent.width
                text: block.player?.trackTitle ?? ""
                emphasized: true
                elide: Text.ElideRight
                font.pixelSize: Looks.font.size.large
                color: Looks.colors.primary
            }

            MText {
                width: parent.width
                visible: text.length > 0
                text: block.player?.trackArtist ?? ""
                elide: Text.ElideRight
                color: Looks.colors.secondary
            }

            MText {
                width: parent.width
                text: block.player?.identity ?? ""
                elide: Text.ElideRight
                font.pixelSize: Looks.font.size.small
                color: Looks.colors.tertiary
            }
        }

        MouseArea {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: art.height
            cursorShape: Qt.PointingHandCursor
            onClicked: MprisController.trackedPlayer = block.player
        }

        Item {
            id: track
            visible: block.length > 0
            anchors {
                left: parent.left
                right: parent.right
                top: art.bottom
                topMargin: 14
            }
            height: 6

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Looks.colors.quaternary
            }

            Rectangle {
                id: elapsed
                width: parent.width * (block.length > 0 ? Math.max(0, Math.min(1, block.position / block.length)) : 0)
                height: parent.height
                radius: height / 2
                color: Looks.colors.primary
            }

            Rectangle {
                visible: block.seekable
                width: 22
                height: 14
                radius: height / 2
                color: Looks.colors.primary
                antialiasing: true
                x: Math.max(0, Math.min(track.width - width, elapsed.width - width / 2))
                anchors.verticalCenter: parent.verticalCenter
                opacity: seekArea.containsMouse ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                id: seekArea
                anchors.fill: parent
                anchors.margins: -8
                enabled: block.seekable
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function seek(x: real) {
                    block.player.position = Math.max(0, Math.min(1, (x + 8) / track.width)) * block.length;
                }

                onPressed: event => seekArea.seek(event.x)
                onPositionChanged: event => {
                    if (seekArea.pressed)
                        seekArea.seek(event.x);
                }
            }
        }

        MText {
            id: position
            anchors {
                left: track.left
                top: track.bottom
                topMargin: 5
            }
            visible: block.length > 0
            text: StringUtils.friendlyTimeForSeconds(block.position)
            font.pixelSize: Looks.font.size.small
            color: Looks.colors.tertiary
        }

        MText {
            anchors {
                right: track.right
                top: track.bottom
                topMargin: 5
            }
            visible: block.length > 0
            text: `-${StringUtils.friendlyTimeForSeconds(Math.max(0, block.length - block.position))}`
            font.pixelSize: Looks.font.size.small
            color: Looks.colors.tertiary
        }

        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: block.length > 0 ? position.bottom : art.bottom
                topMargin: block.length > 0 ? 4 : 12
            }
            spacing: 26

            TransportButton {
                anchors.verticalCenter: parent.verticalCenter
                text: "skip_previous"
                iconSize: 24
                enabled: block.player?.canGoPrevious ?? false
                onActivated: block.player?.previous()
            }

            TransportButton {
                anchors.verticalCenter: parent.verticalCenter
                text: block.player?.isPlaying ? "pause" : "play_arrow"
                iconSize: 32
                enabled: block.player?.canTogglePlaying ?? false
                onActivated: block.player?.togglePlaying()
            }

            TransportButton {
                anchors.verticalCenter: parent.verticalCenter
                text: "skip_next"
                iconSize: 24
                enabled: block.player?.canGoNext ?? false
                onActivated: block.player?.next()
            }
        }
    }

    MouseArea {
        id: header
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 42
        cursorShape: Qt.PointingHandCursor
        onClicked: root.closed()

        MaterialSymbol {
            id: back
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }
            text: "chevron_left"
            iconSize: 20
            color: Looks.colors.secondary
        }

        MText {
            anchors {
                left: back.right
                leftMargin: 4
                verticalCenter: parent.verticalCenter
            }
            text: Translation.tr("Now Playing")
            emphasized: true
            color: Looks.colors.primary
        }
    }

    Column {
        id: playerList
        anchors {
            left: parent.left
            right: parent.right
            top: header.bottom
            leftMargin: 18
            rightMargin: 18
            topMargin: 4
        }
        spacing: 18

        Repeater {
            model: root.players

            PlayerBlock {
                required property MprisPlayer modelData

                width: playerList.width
                player: modelData
            }
        }

        MText {
            visible: root.players.length === 0
            width: parent.width
            height: 60
            text: Translation.tr("Not Playing")
            verticalAlignment: Text.AlignVCenter
            color: Looks.colors.secondary
        }
    }
}
