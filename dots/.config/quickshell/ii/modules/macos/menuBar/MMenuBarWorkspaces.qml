pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.modules.common.models
import qs.modules.macos.looks

Row {
    id: root

    // monitorFor() is a plain function call, so this binding only tracks QsWindow.window.
    // Touching focusedMonitor also re-runs it once Hyprland's IPC data lands.
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen) ?? Hyprland.focusedMonitor

    WorkspaceModel {
        id: workspaces
        monitor: root.monitor
    }

    spacing: Looks.sizes.menuBarItemSpacing

    Repeater {
        model: workspaces.shownCount

        MMenuBarItem {
            id: workspaceItem
            required property int index

            readonly property int workspaceId: workspaces.getWorkspaceIdAt(index)

            minWidth: 30
            horizontalPadding: 5
            active: workspaces.activeWorkspace === workspaceItem.workspaceId
            onClicked: {
                const name = root.monitor?.name ?? "";
                if (name.length > 0)
                    Hyprland.dispatch(`hl.dsp.focus({monitor = "${name}"})`);
                Hyprland.dispatch(`hl.dsp.focus({workspace = ${workspaceItem.workspaceId}})`);
            }

            MText {
                anchors.verticalCenter: parent.verticalCenter
                text: workspaceItem.index + 1
                font.pixelSize: Looks.font.size.small
                color: workspaceItem.active ? Looks.colors.primary : workspaces.occupied[workspaceItem.index] ? Looks.colors.secondary : Looks.colors.tertiary
            }
        }
    }
}
