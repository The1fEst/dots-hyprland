pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

/**
 * Input settings that apply to one device instead of to every device of its kind.
 * A device with no setting of its own follows the general ones.
 */
Singleton {
    id: root

    readonly property string tool: Quickshell.shellPath("scripts/system/hypr-device.py")
    readonly property string file: Quickshell.env("HOME") + "/.config/hypr/settings.lua"

    property var settings: []
    property var mice: []
    property var keyboards: []

    function valueOf(device: string, key: string): string {
        return root.settings.find(setting => setting.device === device && setting.key === key)?.value ?? "";
    }

    function overrides(device: string): int {
        return root.settings.filter(setting => setting.device === device).length;
    }

    property var pending: []

    function set(device: string, key: string, value: string): void {
        if (device.length === 0)
            return;
        root.pending.push(["--set", device, key, value]);
        writeTimer.restart();
    }

    function unset(device: string, key: string): void {
        root.pending.push(["--unset", device, key]);
        writeTimer.restart();
    }

    function reload(): void {
        readProc.running = true;
        devicesProc.running = true;
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
            onStreamFinished: root.settings = JSON.parse(this.text.length > 0 ? this.text : "[]")
        }
    }

    Process {
        id: devicesProc
        running: true
        command: ["hyprctl", "devices", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                const devices = JSON.parse(this.text.length > 0 ? this.text : "{}");
                root.mice = (devices.mice ?? []).map(mouse => mouse.name);
                root.keyboards = (devices.keyboards ?? []).map(keyboard => keyboard.name);
            }
        }
    }

    Timer {
        id: writeTimer
        interval: 50
        onTriggered: {
            if (writeProc.running) {
                writeTimer.restart();
                return;
            }
            if (root.pending.length === 0)
                return;
            const operations = root.pending;
            root.pending = [];
            writeProc.exec(["python3", root.tool, root.file].concat(...operations));
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
