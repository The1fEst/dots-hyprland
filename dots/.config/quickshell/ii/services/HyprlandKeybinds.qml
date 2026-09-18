pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

/**
 * A service that provides access to Hyprland keybinds.
 * Uses the `get_keybinds.py` script to parse comments in config files in a certain format and convert to JSON.
 */
Singleton {
    id: root
    property var keybinds: []
    property var keybindCategories: []

    function modifiers(modmask: int): list<string> {
        const names = [];
        if (modmask & (1 << 2))
            names.push("Ctrl");
        if (modmask & (1 << 6))
            names.push("Super");
        if (modmask & (1 << 0))
            names.push("Shift");
        if (modmask & (1 << 3))
            names.push("Alt");
        if (modmask & (1 << 1))
            names.push("Caps");
        if (modmask & (1 << 4))
            names.push("Mod2");
        if (modmask & (1 << 5))
            names.push("Mod3");
        if (modmask & (1 << 7))
            names.push("Mod5");
        return names;
    }

    function keys(bind: var): list<string> {
        return root.modifiers(bind.modmask ?? 0).concat([bind.key ?? ""]);
    }

    function categoryOf(bind: var): string {
        const description = bind.description ?? "";
        const end = description.indexOf(":");
        return end === -1 ? "" : description.substring(0, end);
    }

    function labelOf(bind: var): string {
        const description = bind.description ?? "";
        const end = description.indexOf(":");
        return end === -1 ? description : description.substring(end + 1).trim();
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name == "configreloaded") {
                getKeybinds.running = true
            }
        }
    }

    Process {
        id: getKeybinds
        running: true
        command: ["hyprctl", "binds", "-j"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.keybinds = JSON.parse(text)
                    var groups = []
                    for (var i = 0; i < root.keybinds.length; i++) {
                        var bind = root.keybinds[i].description
                        var group = bind.substring(0, bind.indexOf(":"))
                        if (!groups.includes(group) && group.length > 0) {
                            groups.push(group)
                        }
                    }
                    root.keybindCategories = groups
                } catch (e) {
                    console.error("[CheatsheetKeybinds] Error parsing keybinds:", e)
                }
            }
        }
    }
}

