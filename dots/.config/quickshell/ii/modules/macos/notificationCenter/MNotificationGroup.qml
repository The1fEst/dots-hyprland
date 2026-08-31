pragma ComponentBehavior: Bound

import QtQuick
import qs.services
import qs.modules.macos.looks

Item {
    id: root

    required property MGlassBackdrop backdrop
    required property var group
    required property bool panelOpen

    property bool expanded: false

    readonly property var items: root.group.notifications
    readonly property int stackedCount: root.expanded ? 0 : Math.min(2, root.items.length - 1)
    readonly property real stackInset: 7
    readonly property real stackPeek: 5

    implicitHeight: root.expanded ? column.implicitHeight : collapsedCard.implicitHeight + root.stackedCount * root.stackPeek

    onPanelOpenChanged: {
        if (!root.panelOpen)
            root.expanded = false;
    }

    Repeater {
        model: root.stackedCount

        MGlass {
            required property int index

            readonly property int depth: root.stackedCount - index

            backdrop: root.backdrop
            x: depth * root.stackInset
            y: depth * root.stackPeek
            width: root.width - depth * root.stackInset * 2
            height: collapsedCard.implicitHeight
        }
    }

    MNotificationCard {
        id: collapsedCard
        visible: !root.expanded
        width: root.width
        backdrop: root.backdrop
        notif: root.items[root.items.length - 1]
        onActivated: {
            if (root.items.length > 1)
                root.expanded = true;
            else
                open();
        }
        onDismissed: Notifications.discardNotification(notif.notificationId)
        onClosed: Notifications.discardNotification(notif.notificationId)
    }

    Column {
        id: column
        visible: root.expanded
        width: root.width
        spacing: 6

        Item {
            width: column.width
            height: 26

            MText {
                anchors {
                    left: parent.left
                    leftMargin: 4
                    verticalCenter: parent.verticalCenter
                }
                text: root.group.appName
                font.pixelSize: Looks.font.size.medium
                emphasized: true
                color: Looks.colors.primary
            }

            Row {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                spacing: 6

                MHeaderButton {
                    backdrop: root.backdrop
                    iconName: "expand_less"
                    label: "Show less"
                    showLabel: !clearButton.hovered
                    onClicked: root.expanded = false
                }

                MHeaderButton {
                    id: clearButton
                    backdrop: root.backdrop
                    iconName: "close"
                    label: "Clear"
                    showLabel: hovered
                    onClicked: {
                        const ids = root.items.map(notif => notif.notificationId);
                        ids.forEach(id => Notifications.discardNotification(id));
                    }
                }
            }
        }

        Repeater {
            model: root.expanded ? root.items.length : 0

            MNotificationCard {
                required property int index

                width: column.width
                backdrop: root.backdrop
                notif: root.items[root.items.length - 1 - index]
                onActivated: open()
                onDismissed: Notifications.discardNotification(notif.notificationId)
                onClosed: Notifications.discardNotification(notif.notificationId)
            }
        }
    }
}
