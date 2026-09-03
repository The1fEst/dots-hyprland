pragma Singleton

import QtQuick
import Quickshell

// The page catalogue and where in it we are. A singleton because pages navigate to each
// other rather than only being reached from the sidebar, and threading that through the
// loader would mean every pane taking a reference to the window.
Singleton {
    id: root

    // `group` only spaces the sidebar; `hidden` keeps a page out of it entirely, for pages
    // another page links to.
    readonly property list<var> pages: [
        {
            group: 0,
            name: qsTr("Wi-Fi"),
            icon: "wifi",
            tint: "#3e8df7",
            pane: "MNetworkPane.qml"
        },
        {
            group: 0,
            name: qsTr("Bluetooth"),
            icon: "bluetooth",
            tint: "#3e8df7",
            pane: "MBluetoothPane.qml"
        }
    ]

    property int currentIndex: 0
    readonly property var currentPage: root.pages[root.currentIndex] ?? null

    // Selecting a page truncates whatever was ahead of it, the way going somewhere new
    // drops the forward history.
    property list<int> history: [0]
    property int historyAt: 0

    function canStep(delta: int): bool {
        const at = root.historyAt + delta;
        return at >= 0 && at < root.history.length;
    }

    function step(delta: int): void {
        if (!root.canStep(delta))
            return;
        root.historyAt += delta;
        root.currentIndex = root.history[root.historyAt];
    }

    function visit(index: int): void {
        if (index < 0 || index >= root.pages.length || index === root.currentIndex)
            return;
        root.history = [...root.history.slice(0, root.historyAt + 1), index];
        root.historyAt = root.history.length - 1;
        root.currentIndex = index;
    }

    function open(name: string): void {
        root.visit(root.pages.findIndex(page => page.name === name));
    }
}
