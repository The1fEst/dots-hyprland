pragma Singleton

import QtQuick
import Quickshell
import qs.modules.common

Singleton {
    id: root

    readonly property real threshold: 6

    property bool active: false
    property string itemId: ""
    property string sourceList: ""
    property string screenName: ""
    // One property rather than separate x and y: a half-updated position would make
    // listeners compute a drop target for a point the cursor was never at.
    property point position: Qt.point(0, 0)

    property string targetList: ""
    property int targetIndex: -1

    function begin(id: string, source: string, screen: string, gx: real, gy: real) {
        root.itemId = id;
        root.sourceList = source;
        root.screenName = screen;
        root.targetList = "";
        root.targetIndex = -1;
        root.position = Qt.point(gx, gy);
        root.active = true;
    }

    function moveTo(gx: real, gy: real) {
        root.position = Qt.point(gx, gy);
    }

    function setTarget(list: string, index: int) {
        root.targetList = list;
        root.targetIndex = index;
    }

    function releaseTarget(owner: string) {
        if (owner === "menuBar" && root.targetList === "menuBar")
            root.setTarget("", -1);
        else if (owner === "controlCenter" && (root.targetList === "controlCenter" || root.targetList === "extras"))
            root.setTarget("", -1);
    }

    function drop() {
        const id = root.itemId;
        const list = root.targetList;
        const index = root.targetIndex;
        const source = root.sourceList;
        root.cancel();

        if (list === "menuBar")
            Config.options.macos.menuBar.items = MItems.withInserted(Config.options.macos.menuBar.items, id, index);
        else if (list === "controlCenter")
            Config.options.macos.controlCenter.controls = MItems.withInserted(Config.options.macos.controlCenter.controls, id, index);
        else if (list === "extras" && source === "menuBar")
            Config.options.macos.menuBar.items = MItems.without(Config.options.macos.menuBar.items, id);
        else if (list === "extras" && source === "controlCenter")
            Config.options.macos.controlCenter.controls = MItems.without(Config.options.macos.controlCenter.controls, id);
    }

    function cancel() {
        root.active = false;
        root.itemId = "";
        root.sourceList = "";
        root.screenName = "";
        root.targetList = "";
        root.targetIndex = -1;
    }
}
