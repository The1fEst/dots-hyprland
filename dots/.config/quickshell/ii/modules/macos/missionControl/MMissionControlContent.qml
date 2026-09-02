pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.macos.looks

Item {
    id: root

    required property var screenData

    readonly property var monitorData: HyprlandData.monitors.find(m => m.name === (root.screenData?.name ?? ""))
    readonly property int activeWorkspace: root.monitorData?.activeWorkspace?.id ?? 1

    // Measured off macOS, as fractions of the screen: the row is not centred in the strip
    // but sits low in it, with most of the slack above.
    readonly property real stripHeight: Math.round(root.height * 0.164)
    readonly property real stripBottomGap: Math.round(root.height * 0.0069)
    readonly property real thumbHeight: Math.round(root.height * 0.077)
    readonly property real thumbGap: Math.round(root.width * 0.018)
    readonly property real labelGap: Math.round(root.height * 0.008)
    readonly property real labelSize: Math.round(root.height * 0.0107)

    // Locking parks the session on workspace 2147483647 - N, which is not a desktop
    // anyone should be offered.
    readonly property list<var> spaces: {
        const found = HyprlandData.workspaces.filter(w => w.monitor === (root.screenData?.name ?? "") && w.id > 0 && w.id < 1000);
        found.sort((a, b) => a.id - b.id);
        return found;
    }

    readonly property list<var> windows: {
        const mon = root.monitorData;
        if (!mon)
            return [];
        const found = [];
        for (const client of HyprlandData.hyprlandClientsForWorkspace(root.activeWorkspace)) {
            if (client.hidden)
                continue;
            found.push({
                address: client.address,
                x: client.at[0] - mon.x,
                y: client.at[1] - mon.y,
                w: Math.max(1, client.size[0]),
                h: Math.max(1, client.size[1]),
                sourceWidth: Math.max(1, client.size[0]),
                sourceHeight: Math.max(1, client.size[1])
            });
        }
        return found;
    }

    readonly property real windowGap: 18

    // Deal the windows into `rows` rows, each holding a comparable share of the total
    // width the row will have to carry.
    function splitRows(list: var, rows: int): var {
        const totalAspect = list.reduce((sum, win) => sum + win.w / win.h, 0);
        const target = totalAspect / rows;
        const buckets = [];
        let current = [];
        let currentAspect = 0;
        for (const win of list) {
            const aspect = win.w / win.h;
            if (current.length > 0 && buckets.length < rows - 1 && currentAspect + aspect / 2 > target) {
                buckets.push(current);
                current = [];
                currentAspect = 0;
            }
            current.push(win);
            currentAspect += aspect;
        }
        if (current.length > 0)
            buckets.push(current);
        return buckets;
    }

    // Give every row the full width, which fixes its height, then bring the stack down to
    // fit the area. Aspect ratios are kept and nothing is blown up past its real size.
    function justify(buckets: var, area: var): var {
        const heights = [];
        for (const row of buckets) {
            const aspectSum = row.reduce((sum, win) => sum + win.w / win.h, 0);
            const usable = area.width - root.windowGap * (row.length - 1);
            if (usable <= 0 || aspectSum <= 0)
                return null;
            heights.push(usable / aspectSum);
        }

        const stack = heights.reduce((sum, h) => sum + h, 0) + root.windowGap * (buckets.length - 1);
        let k = stack > area.height ? area.height / stack : 1;
        for (let i = 0; i < buckets.length; ++i)
            for (const win of buckets[i])
                k = Math.min(k, win.h / heights[i]);
        if (!(k > 0))
            return null;

        const totalHeight = heights.reduce((sum, h) => sum + h * k, 0) + root.windowGap * (buckets.length - 1);
        const items = [];
        let area_ = 0;
        let y = area.y + (area.height - totalHeight) / 2;
        for (let i = 0; i < buckets.length; ++i) {
            const rowHeight = heights[i] * k;
            const widths = buckets[i].map(win => rowHeight * win.w / win.h);
            const rowWidth = widths.reduce((sum, w) => sum + w, 0) + root.windowGap * (buckets[i].length - 1);
            let x = area.x + (area.width - rowWidth) / 2;
            for (let j = 0; j < buckets[i].length; ++j) {
                const win = buckets[i][j];
                items.push({
                    address: win.address,
                    x: x,
                    y: y,
                    w: widths[j],
                    h: rowHeight,
                    sourceWidth: win.sourceWidth,
                    sourceHeight: win.sourceHeight
                });
                area_ += widths[j] * rowHeight;
                x += widths[j] + root.windowGap;
            }
            y += rowHeight + root.windowGap;
        }
        return {
            items: items,
            area: area_
        };
    }

    // Mission Control does not keep windows where they were — it deals them out afresh so
    // that every one of them is visible. Preserving positions would leave a monocle
    // workspace as a single stack with everything but the top window hidden.
    readonly property var layout: {
        // The dock stays out over Mission Control, so the windows are dealt above it.
        const top = root.stripHeight + root.height * 0.03;
        const bottom = root.height - Looks.sizes.dockReservedHeight - root.height * 0.02;
        const area = Qt.rect(root.width * 0.06, top, root.width * 0.88, bottom - top);
        const list = root.windows;
        if (list.length === 0 || area.width <= 0 || area.height <= 0)
            return [];

        // Reading order, so the arrangement still bears some relation to the desktop.
        const ordered = list.slice().sort((a, b) => (a.y - b.y) || (a.x - b.x));

        let best = null;
        for (let rows = 1; rows <= ordered.length; ++rows) {
            const candidate = root.justify(root.splitRows(ordered, rows), area);
            if (candidate && (!best || candidate.area > best.area))
                best = candidate;
        }
        return best ? best.items : [];
    }

    function focusWindow(address: string): void {
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.focus({window="address:${address}"})`]);
        GlobalStates.missionControlOpen = false;
    }

    // Named window rather than the focused one, and without following it: dropping a
    // window on a desktop sends it there, it does not take you along.
    function moveWindow(address: string, workspaceId: int): void {
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.window.move({ workspace = ${workspaceId}, window = "address:${address}", follow = false })`]);
    }

    function focusWorkspace(id: int): void {
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.focus({workspace=${id}})`]);
        GlobalStates.missionControlOpen = false;
    }

    Keys.onEscapePressed: GlobalStates.missionControlOpen = false

    // The real windows are still composited underneath, so the backdrop has to be opaque
    // wallpaper rather than a scrim — Mission Control lifts the windows out and leaves
    // the desktop bare behind them.
    Image {
        id: wallpaper
        anchors.fill: parent
        source: Config.options.background.wallpaperPath
        fillMode: Image.PreserveAspectCrop
        cache: true
        asynchronous: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: GlobalStates.missionControlOpen = false
    }

    Item {
        id: strip
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: root.stripHeight
        clip: true

        // Frosted rather than a flat fill: the plate is the wallpaper blurred until it is
        // even across the whole width. The crop PreserveAspectCrop would pick is spelled
        // out instead, because it is a function of the item's size — sizing this one past
        // the screen to give the blur something to gather at the edges would otherwise
        // reframe it, and the plate would no longer line up with the wallpaper under it.
        Image {
            id: stripSource

            readonly property real fit: Math.max(root.width / Math.max(1, stripSource.implicitWidth), root.height / Math.max(1, stripSource.implicitHeight))

            visible: false
            width: stripSource.implicitWidth * stripSource.fit
            height: stripSource.implicitHeight * stripSource.fit
            x: (root.width - stripSource.width) / 2
            y: (root.height - stripSource.height) / 2
            source: Config.options.background.wallpaperPath
            fillMode: Image.Stretch
            cache: true
            asynchronous: true

            // Decoding small and stretching back up widens the blur past what blurMax can
            // reach. Aspect is untouched, so the framing above still holds.
            sourceSize: Qt.size(66, 36)
            smooth: true
        }

        MultiEffect {
            x: stripSource.x
            y: stripSource.y
            width: stripSource.width
            height: stripSource.height
            source: stripSource
            blurEnabled: true
            blurMax: 64
            blur: 1

            // Without this the effect surrounds the source with transparent padding for
            // the blur to spread into, and the plate dissolves towards the screen edges.
            autoPaddingEnabled: false
            paddingRect: Qt.rect(0, 0, 0, 0)
        }

        Rectangle {
            anchors.fill: parent
            color: "#1f000000"
        }


        Row {
            // Anchored to the bottom of the strip, which is the edge macOS keeps a fixed
            // distance from; the slack all sits above the thumbnails.
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: root.stripBottomGap
            }
            spacing: root.thumbGap

            Repeater {
                model: ScriptModel {
                    values: root.spaces
                    objectProp: "id"
                }

                MSpaceCard {
                    required property var modelData

                    workspaceId: modelData.id
                    monitorData: root.monitorData
                    thumbHeight: root.thumbHeight
                    labelGap: root.labelGap
                    labelSize: root.labelSize
                    current: modelData.id === root.activeWorkspace
                    onActivated: root.focusWorkspace(modelData.id)
                    onWindowDropped: address => root.moveWindow(address, modelData.id)
                }
            }
        }
    }

    Repeater {
        model: ScriptModel {
            values: root.layout
            objectProp: "address"
        }

        MMissionWindow {
            required property var modelData

            toplevel: ToplevelManager.toplevels.values.find(t => HyprlandData.clientForToplevel(t)?.address === modelData.address) ?? null
            address: modelData.address
            dragHeight: root.thumbHeight
            sourceWidth: modelData.sourceWidth
            sourceHeight: modelData.sourceHeight
            x: modelData.x
            y: modelData.y
            width: modelData.w
            height: modelData.h
            onActivated: root.focusWindow(modelData.address)

            Behavior on x {
                NumberAnimation {
                    duration: Looks.animation.normal
                    easing.bezierCurve: Looks.animation.standard
                    easing.type: Easing.BezierSpline
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: Looks.animation.normal
                    easing.bezierCurve: Looks.animation.standard
                    easing.type: Easing.BezierSpline
                }
            }
        }
    }
}
