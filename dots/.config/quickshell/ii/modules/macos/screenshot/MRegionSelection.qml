pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.utils
import qs.modules.common.widgets
import qs.modules.macos.looks

PanelWindow {
    id: root

    property int action: ScreenshotAction.Action.Copy
    property bool windowMode: false
    readonly property bool pointer: Config.options.regionSelector.showPointer
    signal dismiss

    readonly property string screenshotDir: Directories.screenshotTemp
    readonly property string screenshotPath: `${root.screenshotDir}/image-${root.screen.name}`
    readonly property HyprlandMonitor hyprlandMonitor: Hyprland.monitorFor(root.screen)
    readonly property real monitorScale: root.hyprlandMonitor?.scale ?? 1
    readonly property bool recording: root.action === ScreenshotAction.Action.Record || root.action === ScreenshotAction.Action.RecordWithSound

    property bool dragging: false
    property real dragStartX: 0
    property real dragStartY: 0
    property real dragX: 0
    property real dragY: 0

    readonly property real regionX: Math.min(root.dragStartX, root.dragX)
    readonly property real regionY: Math.min(root.dragStartY, root.dragY)
    readonly property real regionWidth: Math.abs(root.dragX - root.dragStartX)
    readonly property real regionHeight: Math.abs(root.dragY - root.dragStartY)

    // Windows on the current workspace, in monitor coordinates.
    readonly property var windowRegions: {
        const workspace = root.hyprlandMonitor?.activeWorkspace?.id ?? -1;
        const offsetX = root.hyprlandMonitor?.x ?? 0;
        const offsetY = root.hyprlandMonitor?.y ?? 0;
        return HyprlandData.windowList.filter(w => w.workspace.id === workspace && !w.hidden).map(w => ({
                    x: w.at[0] - offsetX,
                    y: w.at[1] - offsetY,
                    width: w.size[0],
                    height: w.size[1]
                }));
    }

    readonly property var targeted: root.windowAt(mouseArea.mouseX, mouseArea.mouseY)

    // The clear area: the hovered window while picking one, the drag rectangle otherwise.
    readonly property real clearX: root.windowMode ? (root.targeted?.x ?? 0) : root.regionX
    readonly property real clearY: root.windowMode ? (root.targeted?.y ?? 0) : root.regionY
    readonly property real clearWidth: root.windowMode ? (root.targeted?.width ?? 0) : root.regionWidth
    readonly property real clearHeight: root.windowMode ? (root.targeted?.height ?? 0) : root.regionHeight
    readonly property bool dimmed: root.windowMode || root.dragging

    function windowAt(x: real, y: real): var {
        for (const region of root.windowRegions) {
            if (x >= region.x && x <= region.x + region.width && y >= region.y && y <= region.y + region.height)
                return region;
        }
        return null;
    }

    function capture(x: real, y: real, width: real, height: real, shadow: bool): void {
        if (width < 1 || height < 1) {
            root.dismiss();
            return;
        }
        const clampedX = Math.max(0, Math.min(x, root.screen.width - width));
        const clampedY = Math.max(0, Math.min(y, root.screen.height - height));
        const clampedWidth = Math.max(0, Math.min(width, root.screen.width - clampedX));
        const clampedHeight = Math.max(0, Math.min(height, root.screen.height - clampedY));
        const saveDir = Config.options.screenSnip.savePath !== "" ? Config.options.screenSnip.savePath : "";
        const decorated = shadow && !root.recording;
        Quickshell.execDetached(ScreenshotAction.getCommand(clampedX * root.monitorScale, clampedY * root.monitorScale, clampedWidth * root.monitorScale, clampedHeight * root.monitorScale, root.screenshotPath, root.action, saveDir, decorated, decorated ? root.windowRadius * root.monitorScale : 0));
        root.dismiss();
    }

    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:macosRegionSelector"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    mask: Region {
        item: mouseArea
    }

    // The frozen frame has to exist before the overlay shows, or the first paint is of a
    // screen the user has already covered. The pointer is part of that frame, so turning
    // it on takes the frame again rather than trying to add it at capture time.
    Process {
        id: freezeProc
        running: true
        command: ["bash", "-c", `mkdir -p '${StringUtils.shellSingleQuoteEscape(root.screenshotDir)}' && grim ${root.pointer ? "-c " : ""}-o '${StringUtils.shellSingleQuoteEscape(root.screen.name)}' '${StringUtils.shellSingleQuoteEscape(root.screenshotPath)}'`]
        onExited: {
            // Taken while the overlay is still off screen, so the preview matches the
            // frame the shot will be cut from.
            frozenView.captureFrame();
            root.frozen = true;
        }
    }

    // Asking to record while something is already recording stops it instead of asking
    // for another region.
    property bool frozen: false
    property bool recordingChecked: false
    property bool recordingRunning: false

    Component.onCompleted: {
        if (root.recording)
            stopRecordingProc.running = true;
        else
            root.recordingChecked = true;
    }

    Process {
        id: stopRecordingProc
        command: ["pidof", "wf-recorder"]
        onExited: exitCode => {
            root.recordingRunning = exitCode === 0;
            root.recordingChecked = true;
        }
    }

    onFrozenChanged: root.reveal()
    onRecordingCheckedChanged: root.reveal()

    function reveal(): void {
        if (!root.frozen || !root.recordingChecked)
            return;
        if (root.recording && root.recordingRunning) {
            Quickshell.execDetached([Directories.recordScriptPath]);
            root.dismiss();
            return;
        }
        root.visible = true;
    }

    function refreeze(): void {
        root.visible = false;
        root.frozen = false;
        freezeProc.running = false;
        freezeProc.running = true;
    }

    // Windows are captured off a frame the compositor already rounded, so the shot has
    // to be cut to the same radius to lose the square corners the crop leaves behind.
    property real windowRadius: 0
    Process {
        running: true
        command: ["hyprctl", "getoption", "decoration:rounding", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.windowRadius = JSON.parse(text).int ?? 0
        }
    }

    ScreencopyView {
        id: frozenView
        anchors.fill: parent
        live: false
        captureSource: root.screen
        paintCursor: root.pointer
        focus: root.visible

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.dismiss();
                event.accepted = true;
            } else if (event.key === Qt.Key_Space) {
                root.windowMode = !root.windowMode;
                event.accepted = true;
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: root.windowMode ? Qt.PointingHandCursor : Qt.CrossCursor
        hoverEnabled: true

        onPressed: mouse => {
            if (root.windowMode)
                return;
            root.dragStartX = mouse.x;
            root.dragStartY = mouse.y;
            root.dragX = mouse.x;
            root.dragY = mouse.y;
            root.dragging = true;
        }

        onPositionChanged: mouse => {
            if (!root.dragging)
                return;
            root.dragX = mouse.x;
            root.dragY = mouse.y;
        }

        onReleased: {
            if (root.windowMode) {
                const window = root.targeted;
                if (window)
                    root.capture(window.x, window.y, window.width, window.height, true);
                return;
            }
            root.dragging = false;
            root.capture(root.regionX, root.regionY, root.regionWidth, root.regionHeight, false);
        }

        // Dimming is four plates around the kept area rather than one plate with a hole,
        // so the pixels being captured stay untouched by any blending.
        Item {
            anchors.fill: parent
            visible: root.dimmed
            opacity: 0.45

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: root.clearY
                color: "#000000"
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: parent.height - root.clearY - root.clearHeight
                color: "#000000"
            }

            Rectangle {
                x: 0
                y: root.clearY
                width: root.clearX
                height: root.clearHeight
                color: "#000000"
            }

            Rectangle {
                x: root.clearX + root.clearWidth
                y: root.clearY
                width: parent.width - root.clearX - root.clearWidth
                height: root.clearHeight
                color: "#000000"
            }
        }

        Rectangle {
            id: readout
            x: Math.max(8, Math.min(parent.width - width - 8, mouseArea.mouseX + 16))
            y: Math.max(8, Math.min(parent.height - height - 8, mouseArea.mouseY + 16))
            visible: !root.windowMode
            width: readoutLabel.implicitWidth + 16
            height: 24
            radius: Looks.radius.small
            color: "#cc000000"
            antialiasing: true

            MText {
                id: readoutLabel
                anchors.centerIn: parent
                text: root.dragging ? `${Math.round(root.regionWidth)} × ${Math.round(root.regionHeight)}` : `${Math.round(mouseArea.mouseX)}, ${Math.round(mouseArea.mouseY)}`
                font.family: Looks.font.mono
                color: "#ffffff"
            }
        }

        MCaptureBar {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 40
            }
            visible: !root.dragging
            action: root.action
            windowMode: root.windowMode
            pointer: root.pointer
            onChosen: action => root.action = action
            onModeChosen: windowMode => root.windowMode = windowMode
            onPointerToggled: {
                Config.options.regionSelector.showPointer = !Config.options.regionSelector.showPointer;
                root.refreeze();
            }
            onDismissed: root.dismiss()
        }
    }
}
