pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.services
import qs.modules.common

Item {
    id: root

    property string selected: ""
    property list<var> monitors: HyprlandData.monitors

    signal moved(string name, int x, int y)
    signal picked(string name)

    readonly property real spanLeft: Math.min(...root.monitors.map(m => m.x), 0)
    readonly property real spanTop: Math.min(...root.monitors.map(m => m.y), 0)
    readonly property real spanWidth: Math.max(...root.monitors.map(m => m.x + m.width), 1) - root.spanLeft
    readonly property real spanHeight: Math.max(...root.monitors.map(m => m.y + m.height), 1) - root.spanTop
    readonly property real zoom: Math.min(field.width / Math.max(1, root.spanWidth), field.height / Math.max(1, root.spanHeight)) * 0.9
    readonly property real originX: (field.width - root.spanWidth * root.zoom) / 2
    readonly property real originY: (field.height - root.spanHeight * root.zoom) / 2

    readonly property int snapDistance: 10

    implicitHeight: 240

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

    Rectangle {
        id: field
        anchors.fill: parent
        radius: Appearance.rounding.small
        color: Appearance.colors.colLayer2
        antialiasing: true

        Repeater {
            model: root.monitors

            Item {
                id: plate

                required property var modelData

                readonly property real homeX: (plate.modelData.x - root.spanLeft) * root.zoom + root.originX
                readonly property real homeY: (plate.modelData.y - root.spanTop) * root.zoom + root.originY

                readonly property list<var> neighbours: root.monitors.filter(other => other.name !== plate.modelData.name)
                readonly property bool current: plate.modelData.name === root.selected

                property real placedX: plate.modelData.x
                property real placedY: plate.modelData.y
                property real grabX: 0
                property real grabY: 0

                function coveredBy(px: real, py: real): var {
                    const monitorWidth = plate.modelData.width;
                    const monitorHeight = plate.modelData.height;
                    return plate.neighbours.find(other => px < other.x + other.width && other.x < px + monitorWidth && py < other.y + other.height && other.y < py + monitorHeight) ?? null;
                }

                /**
                 * The nearest spot next to whatever the given one lands on. Two displays
                 * cannot share a pixel of the desktop, so one dropped over another is
                 * moved to the side it is closest to leaving.
                 */
                function besideNeighbours(px: real, py: real): var {
                    const monitorWidth = plate.modelData.width;
                    const monitorHeight = plate.modelData.height;
                    let spotX = px;
                    let spotY = py;
                    for (let tries = plate.neighbours.length + 1; tries > 0; tries--) {
                        const covered = plate.coveredBy(spotX, spotY);
                        if (!covered)
                            break;
                        const sides = [
                            {
                                x: covered.x - monitorWidth,
                                y: spotY
                            },
                            {
                                x: covered.x + covered.width,
                                y: spotY
                            },
                            {
                                x: spotX,
                                y: covered.y - monitorHeight
                            },
                            {
                                x: spotX,
                                y: covered.y + covered.height
                            }
                        ].sort((first, second) => (Math.abs(first.x - spotX) + Math.abs(first.y - spotY)) - (Math.abs(second.x - spotX) + Math.abs(second.y - spotY)));
                        spotX = sides[0].x;
                        spotY = sides[0].y;
                    }
                    return {
                        x: spotX,
                        y: spotY
                    };
                }

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

                    const snapped = plate.besideNeighbours(Math.round(root.snap(root.spanLeft + (px - root.originX) / root.zoom, lefts, reach)), Math.round(root.snap(root.spanTop + (py - root.originY) / root.zoom, tops, reach)));
                    plate.placedX = snapped.x;
                    plate.placedY = snapped.y;
                    plate.x = (plate.placedX - root.spanLeft) * root.zoom + root.originX;
                    plate.y = (plate.placedY - root.spanTop) * root.zoom + root.originY;
                }

                x: plate.homeX
                y: plate.homeY
                width: plate.modelData.width * root.zoom
                height: plate.modelData.height * root.zoom

                Rectangle {
                    anchors.fill: parent
                    radius: Appearance.rounding.verysmall
                    antialiasing: true
                    color: plate.current ? Appearance.colors.colSecondaryContainer : Appearance.colors.colLayer3
                    border.width: drag.active ? 2 : 1
                    border.color: drag.active ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant

                    StyledText {
                        anchors.centerIn: parent
                        text: plate.modelData.model || plate.modelData.name
                        color: plate.current ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer3
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

                TapHandler {
                    onTapped: root.picked(plate.modelData.name)
                }

                HoverHandler {
                    cursorShape: Qt.OpenHandCursor
                }
            }
        }
    }
}
