pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

/**
 * The per-application window rules the settings app owns: one match and one
 * setting each, so a single rule can be taken away again.
 */
Singleton {
    id: root

    readonly property string tool: Quickshell.shellPath("scripts/system/hypr-rules.py")
    readonly property string file: Quickshell.env("HOME") + "/.config/hypr/settings.lua"

    property var rules: []

    function add(windowClass: string, rule: string, value: string): void {
        if (windowClass.length === 0 || rule.length === 0)
            return;
        writeProc.exec(["python3", root.tool, root.file, "--add", windowClass, rule, value]);
    }

    function remove(windowClass: string, rule: string): void {
        writeProc.exec(["python3", root.tool, root.file, "--remove", windowClass, rule]);
    }

    function reload(): void {
        readProc.running = true;
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded")
                root.reload();
        }
    }

    Process {
        id: readProc
        running: true
        command: ["python3", root.tool, "--read", root.file]

        stdout: StdioCollector {
            onStreamFinished: root.rules = JSON.parse(this.text.length > 0 ? this.text : "[]")
        }
    }

    Process {
        id: writeProc
        onExited: applyProc.running = true
    }

    Process {
        id: applyProc
        command: ["hyprctl", "reload"]
        onExited: root.reload()
    }
}
