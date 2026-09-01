pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs
import qs.modules.common.utils

Scope {
    id: root

    property int action: ScreenshotAction.Action.Copy

    function open(action: int): void {
        root.action = action;
        // Re-triggering while open is how a running recording is stopped.
        if (GlobalStates.regionSelectorOpen)
            GlobalStates.regionSelectorOpen = false;
        GlobalStates.regionSelectorOpen = true;
    }

    Variants {
        model: Quickshell.screens

        Loader {
            id: selectorLoader
            required property var modelData

            active: GlobalStates.regionSelectorOpen

            sourceComponent: MRegionSelection {
                screen: selectorLoader.modelData
                action: root.action
                onDismiss: GlobalStates.regionSelectorOpen = false
            }
        }
    }

    IpcHandler {
        target: "region"

        function screenshot(): void {
            root.open(ScreenshotAction.Action.Copy);
        }
        function record(): void {
            root.open(ScreenshotAction.Action.Record);
        }
        function recordWithSound(): void {
            root.open(ScreenshotAction.Action.RecordWithSound);
        }
    }

    GlobalShortcut {
        name: "regionScreenshot"
        description: "Takes a screenshot of the selected region"
        onPressed: root.open(ScreenshotAction.Action.Copy)
    }

    GlobalShortcut {
        name: "regionRecord"
        description: "Records the selected region"
        onPressed: root.open(ScreenshotAction.Action.Record)
    }

    GlobalShortcut {
        name: "regionRecordWithSound"
        description: "Records the selected region with sound"
        onPressed: root.open(ScreenshotAction.Action.RecordWithSound)
    }

}
