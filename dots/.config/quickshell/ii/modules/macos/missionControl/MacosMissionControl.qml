pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs

Scope {
    id: root

    GlobalShortcut {
        name: "overviewWorkspacesToggle"
        description: "Toggles Mission Control on press"

        onPressed: GlobalStates.missionControlOpen = !GlobalStates.missionControlOpen
    }

    GlobalShortcut {
        name: "overviewWorkspacesClose"
        description: "Closes Mission Control on press"

        onPressed: GlobalStates.missionControlOpen = false
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property ShellScreen modelData

            screen: win.modelData
            visible: GlobalStates.missionControlOpen
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.namespace: "quickshell:macosMissionControl"

            // Top, not overlay: the menu bar shares this level and was mapped first, so it
            // ends up underneath, while the dock lifts itself to overlay and stays visible
            // — which is how macOS arranges the two.
            WlrLayershell.layer: WlrLayer.Top

            // The spaces strip takes the top of the screen for itself, menu bar included.
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: GlobalStates.missionControlOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            MMissionControlContent {
                anchors.fill: parent
                screenData: win.modelData
                focus: true
            }
        }
    }
}
