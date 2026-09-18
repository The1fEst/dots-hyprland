pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * The idle timeouts hypridle acts on: locking the session, turning the screens
 * off and suspending. A timeout of zero means it never happens.
 */
Singleton {
    id: root

    readonly property string tool: Quickshell.shellPath("scripts/system/hypr-idle.py")
    readonly property string file: Quickshell.env("HOME") + "/.config/hypr/hypridle.conf"

    property var timeouts: ({})

    function seconds(what: string): int {
        return root.timeouts[what] ?? 0;
    }

    property var pending: ({})

    function set(what: string, seconds: int): void {
        root.pending[what] = seconds;
        writeTimer.restart();
    }

    function reload(): void {
        readProc.running = true;
    }

    Timer {
        id: writeTimer
        interval: 50
        onTriggered: {
            if (writeProc.running) {
                writeTimer.restart();
                return;
            }
            const names = Object.keys(root.pending);
            if (names.length === 0)
                return;
            const pairs = names.map(name => `${name}=${root.pending[name]}`);
            root.pending = ({});
            writeProc.exec(["python3", root.tool, root.file].concat(pairs));
        }
    }

    Process {
        id: readProc
        running: true
        command: ["python3", root.tool, "--read", root.file]

        stdout: StdioCollector {
            onStreamFinished: root.timeouts = JSON.parse(this.text.length > 0 ? this.text : "{}")
        }
    }

    Process {
        id: writeProc
        onExited: applyProc.running = true
    }

    Process {
        id: applyProc
        command: ["bash", "-c", "pkill -x hypridle; hyprctl dispatch exec hypridle"]
        onExited: root.reload()
    }
}
