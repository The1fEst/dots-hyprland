pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

/**
 * Whether a screen recording is running, and how long it has been. The recorder is a
 * process nothing here owns, so the state is read back from the process table rather
 * than remembered: a recording started from a terminal counts just the same. What the
 * shell starts or stops itself shows immediately and is confirmed afterwards.
 */
Singleton {
    id: root

    property bool seen: false
    property bool expecting: false
    property int pendingChecks: 0
    property int seconds: 0

    readonly property bool active: root.seen || root.expecting

    readonly property string elapsed: {
        const minutes = Math.floor(root.seconds / 60);
        const rest = root.seconds % 60;
        return `${minutes}:${rest.toString().padStart(2, "0")}`;
    }

    function refresh(): void {
        checkProc.running = true;
    }

    function watch(): void {
        root.expecting = true;
        root.pendingChecks = 20;
    }

    function stop(): void {
        if (!root.active)
            return;
        Quickshell.execDetached([Directories.recordScriptPath]);
        root.expecting = false;
        root.seen = false;
        root.pendingChecks = 20;
    }

    onActiveChanged: root.seconds = 0

    Process {
        id: checkProc
        running: true
        command: ["pgrep", "wf-recorder"]
        onExited: exitCode => {
            root.seen = (exitCode === 0);
            if (root.seen)
                root.expecting = false;
        }
    }

    Timer {
        running: root.pendingChecks > 0
        repeat: true
        interval: 250
        onTriggered: {
            root.pendingChecks--;
            if (root.pendingChecks === 0)
                root.expecting = false;
            root.refresh();
        }
    }

    Timer {
        running: true
        repeat: true
        interval: root.active ? 1000 : 5000
        onTriggered: {
            root.refresh();
            if (root.active)
                root.seconds++;
        }
    }
}
