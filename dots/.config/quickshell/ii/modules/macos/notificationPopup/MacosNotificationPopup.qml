pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.macos.looks
import qs.modules.macos.notificationCenter

Scope {
    id: root

    PanelWindow {
        id: win

        readonly property real sideMargin: 14

        screen: Quickshell.screens.find(s => Config.options.notifications.forceMonitor.enable ? s.name === Config.options.notifications.forceMonitor.name : s.name === Hyprland.focusedMonitor?.name) ?? null
        visible: Notifications.popupList.length > 0 && !GlobalStates.screenLocked
        color: "transparent"
        exclusiveZone: 0
        implicitWidth: 372
        WlrLayershell.namespace: "quickshell:macosNotificationPopup"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        anchors {
            top: true
            right: true
            bottom: true
        }

        mask: Region {
            item: stack
        }

        Item {
            anchors.fill: parent

            MGlassBackdrop {
                id: backdrop
                screenX: (win.screen?.width ?? 0) - win.width
                screenY: Looks.sizes.menuBarHeight
                panelWidth: win.width
                panelHeight: win.height
                captureWindows: win.visible
            }

            ColumnLayout {
                id: stack
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: win.sideMargin
                }
                spacing: 10

                Repeater {
                    model: Notifications.popupList

                    MNotificationCard {
                        required property var modelData

                        Layout.fillWidth: true
                        backdrop: backdrop
                        notif: modelData
                        onActivated: {
                            focusSender();
                            Notifications.timeoutNotification(modelData.notificationId);
                        }
                        onDismissed: Notifications.timeoutNotification(modelData.notificationId)

                        opacity: 0
                        x: 40

                        Component.onCompleted: {
                            opacity = 1;
                            x = 0;
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on x {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}
