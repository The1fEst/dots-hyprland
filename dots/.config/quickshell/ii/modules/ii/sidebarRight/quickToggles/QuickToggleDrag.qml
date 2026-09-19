pragma Singleton

import QtQuick
import Quickshell
import qs.modules.common

Singleton {
    id: root

    readonly property real threshold: 6

    property bool active: false
    property string type: ""
    property point position: Qt.point(0, 0)

    property string targetList: ""
    property int targetIndex: -1

    function begin(type: string, x: real, y: real): void {
        root.type = type;
        root.targetList = "";
        root.targetIndex = -1;
        root.position = Qt.point(x, y);
        root.active = true;
    }

    function moveTo(x: real, y: real): void {
        root.position = Qt.point(x, y);
    }

    function setTarget(list: string, index: int): void {
        root.targetList = list;
        root.targetIndex = index;
    }

    function releaseTarget(): void {
        root.setTarget("", -1);
    }

    function withInserted(list: var, type: string, index: int): var {
        const kept = (list ?? []).filter(toggle => toggle && toggle.type !== type);
        const existing = (list ?? []).find(toggle => toggle && toggle.type === type);
        const at = index < 0 ? kept.length : Math.max(0, Math.min(index, kept.length));
        kept.splice(at, 0, existing ?? {
            type: type,
            size: 1
        });
        return kept;
    }

    function drop(): void {
        const type = root.type;
        const list = root.targetList;
        const index = root.targetIndex;
        root.cancel();

        const stored = Config.options.sidebar.quickToggles.android.toggles;
        if (list === "used")
            Config.options.sidebar.quickToggles.android.toggles = root.withInserted(stored, type, index);
        else if (list === "unused")
            Config.options.sidebar.quickToggles.android.toggles = (stored ?? []).filter(toggle => toggle && toggle.type !== type);
    }

    function cancel(): void {
        root.active = false;
        root.type = "";
        root.targetList = "";
        root.targetIndex = -1;
    }
}
