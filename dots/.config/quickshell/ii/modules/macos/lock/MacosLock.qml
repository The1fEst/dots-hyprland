pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common.panels.lock

LockScreen {
    id: root

    // Monitor name -> workspace id to restore on unlock, so the lock is not painted over
    // whatever happened to be on screen.
    property var savedWorkspaces: ({})

    lockSurface: MLockSurface {
        context: root.context
    }

    Timer {
        id: restoreTimer
        interval: 150
        onTriggered: {
            let batch = "";
            for (const screen of Quickshell.screens) {
                const workspace = root.savedWorkspaces[screen.name];
                if (workspace === undefined)
                    continue;
                batch += `hyprctl dispatch 'hl.dsp.focus({monitor="${screen.name}"})'; hyprctl dispatch 'hl.dsp.focus({workspace=${workspace}})';`;
            }
            if (batch.length > 0)
                Quickshell.execDetached(["bash", "-c", batch]);
        }
    }

    // One batch for lock and unlock, or the hyprctl calls race each other.
    Connections {
        target: GlobalStates

        function onScreenLockedChanged() {
            if (!GlobalStates.screenLocked) {
                restoreTimer.start();
                return;
            }
            const saved = {};
            let batch = "keyword animation workspaces,1,7,menu_decel,slidevert; ";
            for (const screen of Quickshell.screens) {
                const monitor = HyprlandData.monitors.find(m => m.name === screen.name);
                if (monitor?.activeWorkspace === undefined)
                    return;
                const workspace = monitor?.activeWorkspace?.id ?? 1;
                saved[screen.name] = workspace;
                batch += `hyprctl dispatch 'hl.dsp.focus({monitor="${screen.name}"})'; hyprctl dispatch 'hl.dsp.focus({workspace=${2147483647 - workspace}})';`;
            }
            root.savedWorkspaces = saved;
            Quickshell.execDetached(["bash", "-c", batch]);
        }
    }
}
