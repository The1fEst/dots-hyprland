pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property list<string> names: ["general:gaps_in", "general:gaps_out", "general:border_size", "general:allow_tearing", "decoration:rounding", "decoration:rounding_power","decoration:blur:enabled", "decoration:blur:size", "decoration:blur:passes", "decoration:blur:xray","decoration:active_opacity", "decoration:inactive_opacity", "animations:enabled"]

    property var options: ({})

    readonly property string tool: Quickshell.shellPath("scripts/system/hypr-config.py")
    readonly property string file: Quickshell.env("HOME") + "/.config/hypr/settings.lua"

    function number(name: string): real {
        const raw = root.options[name];
        return typeof raw === "string" ? parseFloat(raw) : (raw ?? 0);
    }

    function numberOr(name: string, fallback: real): real {
        return root.options[name] === undefined ? fallback : root.number(name);
    }

    function flag(name: string): bool {
        return root.options[name] === true;
    }

    function set(name: string, value: var): void {
        writeProc.exec(["python3", root.tool, root.file, `${name}=${value}`]);
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
        command: ["python3", root.tool, "--read"].concat([...root.names])

        stdout: StdioCollector {
            onStreamFinished: root.options = JSON.parse(this.text.length > 0 ? this.text : "{}")
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
