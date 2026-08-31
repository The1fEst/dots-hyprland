pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    property real screenX: 0
    property real screenY: 0
    property real panelWidth: 0
    property real panelHeight: 0
    property real saturation: Looks.glass.saturation
    property real blurMax: Looks.glass.blurMax
    property bool captureWindows: true

    readonly property var screenData: QsWindow.window?.screen ?? null
    readonly property Item sharp: sharpSource
    readonly property Item blurred: blurLayer

    readonly property var monitorData: HyprlandData.monitors.find(m => m.name === (root.screenData?.name ?? ""))
    readonly property int activeWorkspace: monitorData?.activeWorkspace?.id ?? -1

    readonly property list<var> coveredWindows: {
        if (!root.captureWindows)
            return [];
        const left = root.screenX;
        const top = root.screenY;
        const right = left + root.panelWidth;
        const bottom = top + root.panelHeight;
        const monX = root.monitorData?.x ?? 0;
        const monY = root.monitorData?.y ?? 0;
        const found = [];
        for (const toplevel of ToplevelManager.toplevels.values) {
            const client = HyprlandData.clientForToplevel(toplevel);
            if (!client || client.hidden || client.workspace?.id !== root.activeWorkspace)
                continue;
            const x = client.at[0] - monX;
            const y = client.at[1] - monY;
            const w = client.size[0];
            const h = client.size[1];
            if (x + w <= left || x >= right || y + h <= top || y >= bottom)
                continue;
            found.push({
                toplevel: toplevel,
                x: x,
                y: y,
                w: w,
                h: h,
                depth: client.focusHistoryID ?? 0
            });
        }
        found.sort((a, b) => b.depth - a.depth);
        return found;
    }

    visible: false
    x: -screenX
    y: -screenY
    width: screenData?.width ?? 0
    height: screenData?.height ?? 0

    Item {
        id: composite
        anchors.fill: parent
        visible: false

        Image {
            anchors.fill: parent
            source: Config.options.background.wallpaperPath
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(root.width, root.height)
            cache: true
        }

        Repeater {
            model: root.coveredWindows

            ScreencopyView {
                required property var modelData

                captureSource: modelData.toplevel
                live: true
                paintCursor: false
                opacity: hasContent ? 1 : 0
                x: modelData.x
                y: modelData.y
                width: modelData.w
                height: modelData.h
            }
        }
    }

    ShaderEffectSource {
        id: sharpSource
        visible: false
        sourceItem: composite
        live: true
        width: root.width
        height: root.height
    }

    Item {
        id: blurLayer
        anchors.fill: parent
        visible: false
        layer.enabled: true

        MultiEffect {
            source: sharpSource
            anchors.fill: parent
            blurEnabled: true
            blurMax: root.blurMax
            blur: Looks.glass.blur
        }
    }
}
