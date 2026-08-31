pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.modules.macos.looks

PopupWindow {
    id: root

    required property var dock
    property real maxPreviewWidth: 260
    property real maxPreviewHeight: 160

    property var entry: null
    readonly property bool shouldShow: dock.dragIndex < 0 && (entry?.toplevels?.length ?? 0) > 0 && (dock.hoverEntry !== null || hoverKeeper.containsMouse)
    property bool shown: false

    onShouldShowChanged: showTimer.restart()

    Connections {
        target: root.dock

        function onHoverEntryChanged() {
            if (root.dock.hoverEntry)
                root.entry = root.dock.hoverEntry;
        }
    }

    Timer {
        id: showTimer
        interval: 120
        onTriggered: root.shown = root.shouldShow
    }

    anchor {
        window: root.dock
        adjustment: PopupAdjustment.None
        rect: Qt.rect(0, root.dock.height - root.dock.bottomMargin - root.dock.capsuleHeight, root.dock.width, root.dock.capsuleHeight)
        gravity: Edges.Top | Edges.Right
        edges: Edges.Top | Edges.Left
    }

    color: "transparent"
    visible: panel.opacity > 0
    implicitWidth: root.dock.width
    implicitHeight: hoverKeeper.implicitHeight + 16

    MouseArea {
        id: hoverKeeper
        hoverEnabled: true
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        x: Math.max(8, Math.min(root.dock.width - width - 8, root.dock.hoverCenterX - width / 2))
        implicitWidth: panel.implicitWidth
        implicitHeight: panel.implicitHeight

        RectangularShadow {
            anchors.fill: panel
            radius: Looks.radius.large
            blur: Looks.glass.shadowSpread
            spread: 0
            offset: Qt.vector2d(0, 4)
            color: Looks.glass.shadowColor
            opacity: panel.opacity
            cached: true
        }

        Item {
            id: panel
            anchors.fill: parent

            readonly property real radius: Looks.radius.large

            opacity: root.shown ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Looks.animation.fast
                }
            }

            implicitWidth: previewRow.implicitWidth
            implicitHeight: previewRow.implicitHeight

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: Looks.animation.fast
                    easing.type: Easing.OutQuad
                }
            }

            RowLayout {
                id: previewRow
                anchors.fill: parent
                spacing: 8

                Repeater {
                    model: ScriptModel {
                        values: root.entry?.toplevels ?? []
                    }

                    ClippingRectangle {
                        id: windowPreview
                        required property var modelData

                        Layout.preferredWidth: screencopy.implicitWidth
                        Layout.preferredHeight: screencopy.implicitHeight
                        radius: panel.radius
                        color: "transparent"
                        antialiasing: true

                        ScreencopyView {
                            id: screencopy
                            anchors.fill: parent
                            captureSource: windowPreview.modelData
                            live: root.shown
                            paintCursor: false
                            constraintSize: Qt.size(root.maxPreviewWidth, root.maxPreviewHeight)
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: event => {
                                if (event.button === Qt.MiddleButton)
                                    windowPreview.modelData?.close();
                                else
                                    windowPreview.modelData?.activate();
                            }
                        }
                    }
                }
            }
        }
    }
}
