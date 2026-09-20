pragma ComponentBehavior: Bound
import qs
import qs.modules.common
import qs.services
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Scope {
    id: root

    function dismiss() {
        root.recordingScreen = ""
        GlobalStates.regionSelectorOpen = false
    }

    property int captureMode: RegionSelection.CaptureMode.Region

    property string recordingScreen: ""

    Variants {
        model: Quickshell.screens
        delegate: Loader {
            id: regionSelectorLoader
            required property var modelData
            active: GlobalStates.regionSelectorOpen && (root.recordingScreen.length === 0 || root.recordingScreen === regionSelectorLoader.modelData.name)

            sourceComponent: RegionSelection {
                screen: regionSelectorLoader.modelData
                onDismiss: root.dismiss()
                onRecordingStarted: screenName => root.recordingScreen = screenName
                captureMode: root.captureMode
            }
        }
    }

    function screenshot() {
        root.captureMode = RegionSelection.CaptureMode.Region
        root.recordingScreen = ""
        if (GlobalStates.regionSelectorOpen) GlobalStates.regionSelectorOpen = false
        GlobalStates.regionSelectorOpen = true
    }

    Connections {
        target: ScreenRecording
        function onActiveChanged() {
            if (!ScreenRecording.active && root.recordingScreen.length > 0)
                root.dismiss();
        }
    }

    function record() {
        Config.options.regionSelector.recordSound = false
        root.captureMode = RegionSelection.CaptureMode.RecordRegion
        root.recordingScreen = ""
        // If already open then re-trigger to stop recording
        if (GlobalStates.regionSelectorOpen) GlobalStates.regionSelectorOpen = false
        GlobalStates.regionSelectorOpen = true
    }

    function recordWithSound() {
        Config.options.regionSelector.recordSound = true
        root.captureMode = RegionSelection.CaptureMode.RecordRegion
        root.recordingScreen = ""
        // If already open then re-trigger to stop recording
        if (GlobalStates.regionSelectorOpen) GlobalStates.regionSelectorOpen = false
        GlobalStates.regionSelectorOpen = true
    }

    IpcHandler {
        target: "region"

        function screenshot() {
            root.screenshot()
        }
        function record() {
            root.record()
        }
        function recordWithSound() {
            root.recordWithSound()
        }
    }

    GlobalShortcut {
        name: "regionScreenshot"
        description: "Takes a screenshot of the selected region"
        onPressed: root.screenshot()
    }
    GlobalShortcut {
        name: "regionRecord"
        description: "Records the selected region"
        onPressed: root.record()
    }
    GlobalShortcut {
        name: "regionRecordWithSound"
        description: "Records the selected region with sound"
        onPressed: root.recordWithSound()
    }
    GlobalShortcut {
        name: "recordStop"
        description: "Stops the running recording"
        onPressed: ScreenRecording.stop()
    }
}
