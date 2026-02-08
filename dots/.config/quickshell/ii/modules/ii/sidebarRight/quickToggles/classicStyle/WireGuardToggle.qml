import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import Quickshell.Io
import Quickshell

import qs.modules.ii.sidebarRight.wireguardConnections

QuickToggleButton {
    id: root
    toggled: false
    visible: true

    contentItem: CustomIcon {
        source: 'wireguard-symbolic'
        anchors.centerIn: parent
        width: 24
        height: 24
        colorize: true
        color: root.toggled ? Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer1

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
    
    altAction: () => {
        wireguardDialogLoader.active = true
        if (wireguardDialogLoader.item) {
            wireguardDialogLoader.item.show()
        }
    }

    Loader {
        id: wireguardDialogLoader
        active: false
        sourceComponent: WireGuardDialog {
            onDismiss: wireguardDialogLoader.active = false
        }
    }

    onClicked: {
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

    StyledToolTip {
        text: Translation.tr("WireGuard | Right-click to manage connections")
    }
}
