pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import qs.modules.common.models
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    required property var screenData
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screenData) ?? Hyprland.focusedMonitor
    readonly property bool compact: root.width < root.height * 1.6

    function focusWorkspace(id: int): void {
        const name = root.monitor?.name ?? "";
        if (name.length > 0)
            Hyprland.dispatch(`hl.dsp.focus({monitor = "${name}"})`);
        Hyprland.dispatch(`hl.dsp.focus({workspace = ${id}})`);
    }

    WorkspaceModel {
        id: workspaces
        monitor: root.monitor
    }

    MText {
        visible: root.compact
        anchors.centerIn: parent
        text: workspaces.activeWorkspace
        font.pixelSize: Looks.font.size.title
        emphasized: true
        color: Looks.colors.primary
    }

    Row {
        visible: !root.compact
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: workspaces.shownCount

            Rectangle {
                id: tile
                required property int index

                readonly property int workspaceId: workspaces.getWorkspaceIdAt(tile.index)
                readonly property bool active: workspaces.activeWorkspace === tile.workspaceId

                width: 34
                height: 26
                radius: Looks.radius.small
                antialiasing: true
                color: tile.active ? Looks.colors.primary : (hoverArea.containsMouse ? Looks.colors.tertiary : Looks.colors.quaternary)

                MText {
                    anchors.centerIn: parent
                    text: tile.index + 1
                    color: tile.active ? (Looks.dark ? "#000000" : "#ffffff") : (workspaces.occupied[tile.index] ? Looks.colors.primary : Looks.colors.tertiary)
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.focusWorkspace(tile.workspaceId)
                }
            }
        }
    }
}
