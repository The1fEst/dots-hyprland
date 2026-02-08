import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import Quickshell
import Quickshell.Io

QuickToggleModel {
    id: root
    name: Translation.tr("WireGuard")

    toggled: false
    icon: "vpn_key"
    hasMenu: true
    mainAction: () => {
        if (root.toggled) {
            Quickshell.execDetached(["nmcli", "connection", "down", "WireGuard"])
        } else {
            Quickshell.execDetached(["nmcli", "connection", "up", "WireGuard"])
        }
        // Check state after a short delay to allow command to execute
        refreshTimer.restart()
    }

    Timer {
        id: refreshTimer
        interval: 500
        onTriggered: {
            checkConnectionState.running = true
        }
    }

    Timer {
        id: pollTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: checkConnectionState.running = true
    }

    Process {
        id: fetchActiveState
        running: true
        command: ["bash", "-c", "nmcli connection show --active | grep -q WireGuard"]
        onExited: (exitCode, exitStatus) => {
            root.toggled = exitCode === 0
        }
    }

    Process {
        id: checkConnectionState
        command: ["bash", "-c", "nmcli connection show --active | grep -q WireGuard"]
        onExited: (exitCode, exitStatus) => {
            root.toggled = exitCode === 0
        }
    }

    tooltipText: Translation.tr("WireGuard")
}
