pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
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

    property bool pinned: Config.options?.osk.pinnedOnStartup ?? false

    Loader {
        id: oskLoader
        active: GlobalStates.oskOpen

        onActiveChanged: {
            if (!oskLoader.active)
                Ydotool.releaseAllKeys();
        }

        sourceComponent: PanelWindow {
            id: win

            readonly property real margin: 16

            visible: oskLoader.active && !GlobalStates.screenLocked
            color: "transparent"
            WlrLayershell.namespace: "quickshell:macosOsk"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusiveZone: root.pinned ? win.implicitHeight : 0
            implicitWidth: layout.implicitWidth + win.margin * 2 + Looks.sizes.shadowMargin * 2
            implicitHeight: layout.implicitHeight + win.margin * 2 + Looks.sizes.shadowMargin * 2
            anchors.bottom: true

            mask: Region {
                item: layout
            }

            // Panels of this shell are grabbed away by a click elsewhere; the keyboard
            // has to survive that, or typing into anything would close it.
            Component.onCompleted: GlobalFocusGrab.addPersistent(win)
            Component.onDestruction: GlobalFocusGrab.removePersistent(win)

            MGlassBackdrop {
                id: backdrop
                screenX: ((win.screen?.width ?? 0) - win.width) / 2
                screenY: (win.screen?.height ?? 0) - win.height
                panelWidth: win.width
                panelHeight: win.height
                captureWindows: win.visible
            }

            RowLayout {
                id: layout
                anchors.centerIn: parent
                spacing: 6

                ColumnLayout {
                    spacing: 6

                    ControlKey {
                        icon: "language"
                        onActivated: Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"])
                    }

                    ControlKey {
                        icon: "keep"
                        lit: root.pinned
                        onActivated: root.pinned = !root.pinned
                    }

                    ControlKey {
                        icon: "keyboard_hide"
                        onActivated: GlobalStates.oskOpen = false
                    }
                }

                MOskContent {
                    backdrop: backdrop
                    Layout.fillWidth: true
                }
            }

            component ControlKey: MGlass {
                id: controlKey

                property string icon: ""
                property bool lit: false

                signal activated

                backdrop: backdrop
                implicitWidth: 44
                implicitHeight: 42
                radius: Looks.radius.normal
                tint: controlKey.lit ? Looks.accent : Looks.glass.tint

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: controlKey.icon
                    iconSize: 20
                    color: controlKey.lit ? "#ffffff" : Looks.colors.primary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: controlKey.activated()
                }
            }
        }
    }

    IpcHandler {
        target: "osk"

        function toggle(): void {
            GlobalStates.oskOpen = !GlobalStates.oskOpen;
        }

        function close(): void {
            GlobalStates.oskOpen = false;
        }

        function open(): void {
            GlobalStates.oskOpen = true;
        }
    }

    GlobalShortcut {
        name: "oskToggle"
        description: "Toggles on screen keyboard on press"
        onPressed: GlobalStates.oskOpen = !GlobalStates.oskOpen
    }

    GlobalShortcut {
        name: "oskOpen"
        description: "Opens on screen keyboard on press"
        onPressed: GlobalStates.oskOpen = true
    }

    GlobalShortcut {
        name: "oskClose"
        description: "Closes on screen keyboard on press"
        onPressed: GlobalStates.oskOpen = false
    }
}
