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
        readonly property int bannerDuration: 3000

        // One banner at a time, oldest first. The queue is kept here rather than read
        // from popupList because the service starts each notification's timer when it
        // arrives, which would expire the ones still waiting their turn.
        property var queue: []
        property bool replying: false
        readonly property var current: win.queue.length > 0 ? win.queue[0] : null

        // Discarded banners are gone for good; timed out ones stay for the notification
        // centre.
        function advance(discard: bool) {
            const shown = win.current;
            win.replying = false;
            win.queue = win.queue.slice(1);
            if (!shown)
                return;
            if (discard)
                Notifications.discardNotification(shown.notificationId);
            else
                Notifications.timeoutNotification(shown.notificationId);
        }

        onCurrentChanged: if (win.current)
            bannerTimer.restart()

        // A banner being replied to waits for the reply instead of timing out under it.
        onReplyingChanged: {
            if (win.replying)
                bannerTimer.stop();
            else if (win.current)
                bannerTimer.restart();
        }

        Connections {
            target: Notifications

            function onNotify(notif) {
                if (Notifications.popupInhibited)
                    return;
                win.queue = [...win.queue, notif];
            }

            // Dropping a notification elsewhere, Clear All say, must not leave it queued
            // to pop up later.
            function onListChanged() {
                win.queue = win.queue.filter(queued => {
                    for (const notif of Notifications.list) {
                        if (notif === queued)
                            return true;
                    }
                    return false;
                });
            }
        }

        Timer {
            id: bannerTimer
            interval: win.bannerDuration
            onTriggered: win.advance(false)
        }

        screen: Quickshell.screens.find(s => Config.options.notifications.forceMonitor.enable ? s.name === Config.options.notifications.forceMonitor.name : s.name === Hyprland.focusedMonitor?.name) ?? null
        visible: win.current !== null && !GlobalStates.screenLocked
        color: "transparent"
        exclusiveZone: 0
        implicitWidth: 372
        WlrLayershell.namespace: "quickshell:macosNotificationPopup"
        WlrLayershell.layer: WlrLayer.Overlay
        // On demand only for banners that can be replied to: the compositor then hands
        // the keyboard over when the reply field is clicked, and never otherwise.
        WlrLayershell.keyboardFocus: (win.current?.hasInlineReply ?? false) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
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
                    model: win.current ? [win.current] : []

                    MNotificationCard {
                        required property var modelData

                        Layout.fillWidth: true
                        backdrop: backdrop
                        notif: modelData
                        onActivated: {
                            open();
                            win.advance(true);
                        }
                        onDismissed: win.advance(true)
                        onClosed: win.advance(true)
                        onReplyingChanged: win.replying = replying
                        Component.onDestruction: win.replying = false

                        // Pointing at a banner is a request to keep it around.
                        onHoveredChanged: {
                            if (hovered)
                                bannerTimer.stop();
                            else if (!win.replying)
                                bannerTimer.restart();
                        }

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
