pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string cursorTheme: ""
    property int cursorSize: 24
    property var fonts: ({})
    property string iconTheme: ""
    property string gtkTheme: ""
    property string qtStyle: ""

    property list<string> cursorThemes: []
    property list<string> iconThemes: []
    property list<string> gtkThemes: []
    property list<string> qtStyles: []
    property list<int> sizes: []

    property var families: ({})
    property list<string> familyNames: []

    readonly property string tool: Quickshell.shellPath("scripts/system/appearance.py")

    function reload(): void {
        readProc.running = true;
    }

    function loadFamilies(): void {
        familiesProc.running = true;
    }

    function apply(args: list<string>): void {
        writeProc.exec(["python3", root.tool].concat(args));
    }

    function setCursor(theme: string, size: int): void {
        root.apply(["cursor", theme, String(size)]);
    }

    function setIcons(theme: string): void {
        root.apply(["icons", theme]);
    }

    function setFont(role: string, parts: var): void {
        const args = ["font", role];
        for (const name of ["family", "style", "size"]) {
            if (parts[name] !== undefined)
                args.push(`--${name}`, String(parts[name]));
        }
        if (args.length > 2)
            root.apply(args);
    }

    function setThemes(gtk: string, qt: string): void {
        root.apply(["theme", "--gtk", gtk, "--qt", qt]);
    }

    Process {
        id: readProc
        running: true
        command: ["python3", root.tool, "--read"]

        stdout: StdioCollector {
            onStreamFinished: {
                const state = JSON.parse(this.text.length > 0 ? this.text : "{}");
                root.cursorTheme = state.cursorTheme ?? "";
                root.cursorSize = state.cursorSize ?? 24;
                root.fonts = state.fonts ?? ({});
                root.iconTheme = state.iconTheme ?? "";
                root.gtkTheme = state.gtkTheme ?? "";
                root.qtStyle = state.qtStyle ?? "";
                root.cursorThemes = state.cursorThemes ?? [];
                root.iconThemes = state.iconThemes ?? [];
                root.gtkThemes = state.gtkThemes ?? [];
                root.qtStyles = state.qtStyles ?? [];
                root.sizes = state.sizes ?? [];
            }
        }
    }

    Process {
        id: familiesProc
        command: ["python3", root.tool, "--families"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.families = JSON.parse(this.text.length > 0 ? this.text : "{}");
                root.familyNames = Object.keys(root.families);
            }
        }
    }

    Process {
        id: writeProc
        onExited: root.reload()
    }
}
