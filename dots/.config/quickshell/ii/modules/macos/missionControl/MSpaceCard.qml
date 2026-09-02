pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.macos.looks

// A desktop in the top strip: the wallpaper with that workspace's windows laid over it at
// the same relative positions they hold on the real screen.
Item {
    id: root

    required property int workspaceId
    required property var monitorData
    required property real thumbHeight
    required property real labelGap
    required property real labelSize
    required property bool current

    signal activated
    signal windowDropped(string address)

    readonly property real logicalWidth: Math.max(1, (monitorData?.width ?? 1920) / (monitorData?.scale ?? 1))
    readonly property real logicalHeight: Math.max(1, (monitorData?.height ?? 1080) / (monitorData?.scale ?? 1))

    implicitWidth: Math.round(root.thumbHeight * root.logicalWidth / root.logicalHeight)
    implicitHeight: root.thumbHeight + root.labelGap + label.height

    ClippingRectangle {
        id: card

        readonly property real ratio: card.width / root.logicalWidth

        width: parent.width
        height: root.thumbHeight
        radius: Looks.radius.small
        color: "#000000"
        antialiasing: true

        Image {
            anchors.fill: parent
            source: Config.options.background.wallpaperPath
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(Math.max(1, card.width) * 2, Math.max(1, card.height) * 2)
            cache: true
            asynchronous: true
        }

        Repeater {
            model: ScriptModel {
                values: HyprlandData.hyprlandClientsForWorkspace(root.workspaceId).filter(client => !client.hidden)
                objectProp: "address"
            }

            MMissionWindow {
                required property var modelData

                toplevel: ToplevelManager.toplevels.values.find(t => HyprlandData.clientForToplevel(t)?.address === modelData.address) ?? null
                address: modelData.address
                sourceWidth: modelData.size[0]
                sourceHeight: modelData.size[1]
                interactive: false
                x: (modelData.at[0] - (root.monitorData?.x ?? 0)) * card.ratio
                y: (modelData.at[1] - (root.monitorData?.y ?? 0)) * card.ratio
                width: modelData.size[0] * card.ratio
                height: modelData.size[1] * card.ratio
            }
        }
    }

    // Fills the whole card, label included, so the drop target is the desktop's column in
    // the strip rather than just the thumbnail.
    DropArea {
        id: dropTarget
        anchors.fill: parent
        keys: ["macosMissionWindow"]

        onDropped: drop => {
            root.windowDropped(drop.source.address);
            drop.accept(Qt.MoveAction);
        }
    }

    // macOS stands the selection ring off the thumbnail rather than drawing it on the
    // edge, which is what makes the current desktop sit proud of the others.
    Rectangle {
        readonly property bool lit: root.current || dropTarget.containsDrag
        readonly property real outset: lit ? Math.round(root.thumbHeight * 0.06) : 0

        anchors.fill: card
        anchors.margins: -outset
        color: "transparent"
        radius: card.radius + outset
        antialiasing: true
        border.width: lit ? 3 : 1
        border.color: lit ? Looks.accent : Looks.colors.glassBorder
    }

    MText {
        id: label
        anchors {
            top: card.bottom
            topMargin: root.labelGap
            horizontalCenter: parent.horizontalCenter
        }
        text: Translation.tr("Desktop %1").arg(root.workspaceId)
        font.pixelSize: root.labelSize
        color: root.current ? "#ffffff" : Looks.colors.secondary
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
