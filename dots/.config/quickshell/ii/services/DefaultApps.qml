pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Which application opens each kind of file or link, and which ones offer to.
 */
Singleton {
    id: root

    readonly property string tool: Quickshell.shellPath("scripts/system/default-apps.py")

    property var roles: []

    function set(mime: string, entry: string): void {
        writeProc.exec(["python3", root.tool, mime, entry]);
    }

    function reload(): void {
        readProc.running = true;
    }

    Process {
        id: readProc
        running: true
        command: ["python3", root.tool, "--read"]

        stdout: StdioCollector {
            onStreamFinished: root.roles = JSON.parse(this.text.length > 0 ? this.text : "[]")
        }
    }

    Process {
        id: writeProc
        onExited: root.reload()
    }

    Connections {
        target: DesktopEntries.applications

        function onValuesChanged(): void {
            rescanTimer.restart();
        }
    }

    Timer {
        id: rescanTimer
        interval: 1000
        onTriggered: root.reload()
    }
}
