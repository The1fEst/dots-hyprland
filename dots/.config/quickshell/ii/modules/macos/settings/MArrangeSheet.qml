pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Widgets
import qs.modules.common.widgets
import qs.modules.macos.controls
import qs.modules.macos.looks

Popup {
    id: root

    property list<var> monitors: []
    property string wallpaper: ""

    signal moved(string name, int x, int y)

    readonly property real spanLeft: Math.min(...root.monitors.map(m => m.x), 0)
    readonly property real spanTop: Math.min(...root.monitors.map(m => m.y), 0)
    readonly property real spanWidth: Math.max(...root.monitors.map(m => m.x + m.width), 1) - root.spanLeft
    readonly property real spanHeight: Math.max(...root.monitors.map(m => m.y + m.height), 1) - root.spanTop
    readonly property real zoom: Math.min(field.width / Math.max(1, root.spanWidth), field.height / Math.max(1, root.spanHeight)) * 0.9
    readonly property real originX: (field.width - root.spanWidth * root.zoom) / 2
    readonly property real originY: (field.height - root.spanHeight * root.zoom) / 2

    readonly property int snapDistance: 10
    readonly property int fieldHeight: 240

    function snap(value: real, edges: list<real>, reach: real): real {
        let best = value;
        let closest = reach;
        for (const edge of edges) {
            const distance = Math.abs(edge - value);
            if (distance >= closest)
                continue;
            closest = distance;
            best = edge;
        }
        return best;
    }

    width: 560
    padding: Looks.settings.sheetPadding
    modal: true
    dim: true
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape

    background: Rectangle {
        radius: Looks.radius.window
        color: Looks.surfaces.panel
        antialiasing: true
    }

    contentItem: Column {
        spacing: Looks.settings.formRowLabelGap

        MText {
            text: qsTr("Arrange Displays")
            emphasized: true
        }

        MText {
            width: parent.width
            text: qsTr("To rearrange displays, drag them to the desired position. The display holding the menu bar is the one at the top left.")
            textStyle: Looks.font.style.subheadline
            lineHeight: Looks.font.style.subheadline.lineHeight
            lineHeightMode: Text.FixedHeight
            wrapMode: Text.WordWrap
            color: Looks.colors.secondary
        }

        Item {
            width: parent.width
            height: root.fieldHeight

            Rectangle {
                id: field
                anchors.fill: parent
                anchors.topMargin: Looks.settings.formGap
                radius: Looks.settings.formRadius
                color: Looks.colors.seximal
                antialiasing: true

                Repeater {
                    model: root.monitors

                    Item {
                        id: plate

                        required property var modelData

                        readonly property real homeX: (plate.modelData.x - root.spanLeft) * root.zoom + root.originX
                        readonly property real homeY: (plate.modelData.y - root.spanTop) * root.zoom + root.originY

                        readonly property list<var> neighbours: root.monitors.filter(other => other.name !== plate.modelData.name)

                        property real placedX: plate.modelData.x
                        property real placedY: plate.modelData.y
                        property real grabX: 0
                        property real grabY: 0

                        function place(px: real, py: real): void {
                            const reach = root.snapDistance / root.zoom;
                            const monitorWidth = plate.modelData.width;
                            const monitorHeight = plate.modelData.height;

                            const lefts = [];
                            const tops = [];
                            for (const other of plate.neighbours) {
                                lefts.push(other.x, other.x + other.width, other.x - monitorWidth, other.x + other.width - monitorWidth);
                                tops.push(other.y, other.y + other.height, other.y - monitorHeight, other.y + other.height - monitorHeight);
                            }

                            plate.placedX = Math.round(root.snap(root.spanLeft + (px - root.originX) / root.zoom, lefts, reach));
                            plate.placedY = Math.round(root.snap(root.spanTop + (py - root.originY) / root.zoom, tops, reach));
                            plate.x = (plate.placedX - root.spanLeft) * root.zoom + root.originX;
                            plate.y = (plate.placedY - root.spanTop) * root.zoom + root.originY;
                        }

                        x: plate.homeX
                        y: plate.homeY
                        width: plate.modelData.width * root.zoom
                        height: plate.modelData.height * root.zoom

                        ClippingRectangle {
                            id: face
                            anchors.fill: parent
                            radius: Looks.radius.tiny
                            antialiasing: true
                            color: Looks.colors.quaternary
                            border.width: drag.active ? 2 : 1
                            border.color: drag.active ? Looks.accent : Looks.colors.tertiary

                            StyledImage {
                                anchors.fill: parent
                                anchors.margins: face.border.width
                                source: root.wallpaper.length > 0 ? "file://" + root.wallpaper : ""
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(plate.width * 2, plate.height * 2)
                            }
                        }

                        DragHandler {
                            id: drag
                            target: null

                            onActiveChanged: {
                                if (drag.active) {
                                    plate.grabX = plate.x;
                                    plate.grabY = plate.y;
                                    return;
                                }
                                const x = plate.placedX;
                                const y = plate.placedY;
                                plate.x = Qt.binding(() => plate.homeX);
                                plate.y = Qt.binding(() => plate.homeY);
                                root.moved(plate.modelData.name, x, y);
                            }

                            onActiveTranslationChanged: {
                                if (drag.active)
                                    plate.place(plate.grabX + drag.activeTranslation.x, plate.grabY + drag.activeTranslation.y);
                            }
                        }

                        HoverHandler {
                            cursorShape: Qt.OpenHandCursor
                        }
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: Looks.settings.sheetFooterHeight

            MPushButton {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                controlHeight: Looks.control.large
                minimumWidth: Looks.settings.sheetButtonWidth
                label: qsTr("Done")
                prominent: true
                onClicked: root.close()
            }
        }
    }
}
