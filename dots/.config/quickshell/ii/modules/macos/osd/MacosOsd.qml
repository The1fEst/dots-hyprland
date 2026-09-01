pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.macos.looks

Scope {
    id: root

    readonly property int segments: 16
    property string indicator: "volume"
    property string protectionMessage: ""

    readonly property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
    readonly property var brightnessMonitor: Brightness.getMonitorForScreen(root.focusedScreen)

    readonly property bool muted: (Audio.sink?.audio.muted ?? false) && root.indicator === "volume"

    readonly property real value: {
        if (root.indicator === "brightness")
            return root.brightnessMonitor?.brightness ?? 0;
        if (root.indicator === "gamma") {
            const lower = Hyprsunset.gammaLowerLimit;
            return (Hyprsunset.gamma - lower) / (100 - lower);
        }
        if (root.muted)
            return 0;
        return Audio.sink?.audio.volume ?? 0;
    }

    readonly property string glyph: {
        if (root.indicator === "brightness")
            return Hyprsunset.temperatureActive ? "routine" : "light_mode";
        if (root.indicator === "gamma")
            return "wb_twilight";
        if (root.muted)
            return "volume_off";
        return root.value > 0.5 ? "volume_up" : (root.value > 0 ? "volume_down" : "volume_mute");
    }

    function trigger(which: string): void {
        root.indicator = which;
        GlobalStates.osdVolumeOpen = true;
        osdTimeout.restart();
    }

    Timer {
        id: osdTimeout
        interval: Config.options.osd.timeout
        onTriggered: {
            GlobalStates.osdVolumeOpen = false;
            root.protectionMessage = "";
        }
    }

    Connections {
        target: Brightness

        function onBrightnessChanged() {
            root.protectionMessage = "";
            root.trigger("brightness");
        }
    }

    Connections {
        target: Hyprsunset

        function onGammaChangeAttempt() {
            root.protectionMessage = "";
            root.trigger("gamma");
        }
    }

    Connections {
        target: Audio.sink?.audio ?? null

        function onVolumeChanged() {
            if (!Audio.ready)
                return;
            root.trigger("volume");
        }

        function onMutedChanged() {
            if (!Audio.ready)
                return;
            root.trigger("volume");
        }
    }

    Connections {
        target: Audio

        function onSinkProtectionTriggered(reason) {
            root.protectionMessage = reason;
            root.trigger("volume");
        }
    }

    PanelWindow {
        id: win

        readonly property real cardSize: 200
        readonly property real bottomInset: 140

        screen: root.focusedScreen
        visible: GlobalStates.osdVolumeOpen || card.opacity > 0
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        implicitWidth: win.cardSize + Looks.sizes.shadowMargin * 2
        implicitHeight: win.cardSize + Looks.sizes.shadowMargin * 2
        WlrLayershell.namespace: "quickshell:macosOsd"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        anchors.bottom: true
        margins.bottom: win.bottomInset - Looks.sizes.shadowMargin

        mask: Region {}

        MGlassBackdrop {
            id: backdrop
            anchors.fill: parent
            screenX: ((win.screen?.width ?? 0) - win.width) / 2
            screenY: (win.screen?.height ?? 0) - win.height - win.margins.bottom
            panelWidth: win.width
            panelHeight: win.height
            captureWindows: win.visible
        }

        MGlass {
            id: card
            backdrop: backdrop
            anchors.centerIn: parent
            width: win.cardSize
            height: win.cardSize
            opacity: GlobalStates.osdVolumeOpen ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Looks.animation.fast
                    easing.type: Easing.OutCubic
                }
            }

            MaterialSymbol {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -14
                }
                text: root.glyph
                iconSize: 88
                fill: 1
                color: Looks.colors.primary
            }

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: 24
                    rightMargin: 24
                    bottomMargin: 26
                }
                spacing: 3

                Repeater {
                    model: root.segments

                    Rectangle {
                        required property int index

                        width: (card.width - 48 - (root.segments - 1) * 3) / root.segments
                        height: 7
                        radius: 2
                        antialiasing: true
                        color: index < Math.round(Math.min(1, Math.max(0, root.value)) * root.segments) ? Looks.colors.primary : Looks.colors.tertiary
                    }
                }
            }
        }

        MGlass {
            backdrop: backdrop
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: card.bottom
                topMargin: 12
            }
            width: protectionLabel.implicitWidth + 32
            height: 34
            visible: root.protectionMessage.length > 0
            opacity: card.opacity
            tint: Looks.colors.red

            MText {
                id: protectionLabel
                anchors.centerIn: parent
                text: root.protectionMessage
                font.pixelSize: Looks.font.size.medium
                emphasized: true
                color: "#ffffff"
            }
        }
    }

    IpcHandler {
        target: "osdVolume"

        function trigger(): void {
            root.trigger("volume");
        }

        function hide(): void {
            GlobalStates.osdVolumeOpen = false;
        }

        function toggle(): void {
            if (GlobalStates.osdVolumeOpen)
                GlobalStates.osdVolumeOpen = false;
            else
                root.trigger("volume");
        }
    }

    GlobalShortcut {
        name: "osdVolumeTrigger"
        description: "Triggers volume OSD on press"

        onPressed: root.trigger("volume")
    }

    GlobalShortcut {
        name: "osdVolumeHide"
        description: "Hides volume OSD on press"

        onPressed: GlobalStates.osdVolumeOpen = false
    }
}
