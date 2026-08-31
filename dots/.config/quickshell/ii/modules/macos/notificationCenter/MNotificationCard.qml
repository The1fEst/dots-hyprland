pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    required property var notif
    property int maximumBodyLines: 3

    readonly property bool hovered: hoverArea.containsMouse || closeArea.containsMouse || replyField.containsMouse
    readonly property bool canReply: root.notif.hasInlineReply ?? false
    // Kept open while it holds focus or a half typed reply, so it does not vanish the
    // moment the pointer drifts off the card.
    readonly property bool replying: root.canReply && (root.hovered || replyInput.activeFocus || replyInput.text.length > 0)

    // One value drives the whole reveal: the card's extra height, how far the text moves
    // up and the field's own fade.
    property real replyReveal: root.replying ? 1 : 0

    Behavior on replyReveal {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    signal activated
    signal dismissed
    signal closed

    function sendReply(): void {
        if (replyInput.text.length === 0)
            return;
        Notifications.sendInlineReply(root.notif.notificationId, replyInput.text);
        root.replying = false;
    }


    function open(): void {
        // Applications offer the click as an action named "default"; invoking it opens
        // the conversation or page the notification is about rather than any window of
        // the app. Notifications restored from disk carry no actions, so those fall
        // through to the window below.
        for (const action of root.notif.actions ?? []) {
            if (action.identifier !== "default")
                continue;
            Notifications.attemptInvokeAction(root.notif.notificationId, action.identifier);
            return;
        }
        if (root.focusSender())
            return;
        DesktopEntries.heuristicLookup(root.notif.appName)?.execute();
    }

    function focusSender(): bool {
        const wanted = (root.notif.appName ?? "").toLowerCase();
        if (wanted.length === 0)
            return false;
        for (const toplevel of ToplevelManager.toplevels.values) {
            const appId = (toplevel.appId ?? "").toLowerCase();
            if (appId.length === 0)
                continue;
            const entryName = (DesktopEntries.heuristicLookup(toplevel.appId)?.name ?? "").toLowerCase();
            if (appId === wanted || appId.endsWith(`.${wanted}`) || appId.includes(wanted) || wanted.includes(appId) || entryName === wanted) {
                toplevel.activate();
                return true;
            }
        }
        return false;
    }

    readonly property string stamp: {
        const now = new Date();
        const then = new Date(root.notif.time);
        const days = Math.floor((now.setHours(0, 0, 0, 0) - new Date(root.notif.time).setHours(0, 0, 0, 0)) / 86400000);
        if (days <= 0)
            return Qt.locale().toString(then, "h:mm AP");
        if (days === 1)
            return `Yesterday, ${Qt.locale().toString(then, "h:mm AP")}`;
        return `${days} days ago`;
    }

    implicitHeight: Math.max(64, textColumn.implicitHeight + 26) + 44 * root.replyReveal

    ClippingRectangle {
        id: icon
        anchors {
            left: parent.left
            leftMargin: 16
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -22 * root.replyReveal
        }
        width: 32
        height: 32
        radius: 8
        color: "transparent"
        antialiasing: true

        IconImage {
            anchors.fill: parent
            source: root.notif.appIcon.length > 0 ? Quickshell.iconPath(root.notif.appIcon, true) || Quickshell.iconPath(AppSearch.guessIcon(root.notif.appName), "image-missing") : Quickshell.iconPath(AppSearch.guessIcon(root.notif.appName), "image-missing")
            smooth: true
        }
    }

    MText {
        id: stampLabel
        anchors {
            right: parent.right
            rightMargin: 16
            top: textColumn.top
        }
        text: root.stamp
        font.pixelSize: Looks.font.size.small
        color: Looks.colors.secondary
        opacity: root.hovered ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }
    }

    Column {
        id: textColumn
        anchors {
            left: icon.right
            leftMargin: 12
            right: stampLabel.left
            rightMargin: 8
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -22 * root.replyReveal
        }
        spacing: 1

        MText {
            width: parent.width
            text: root.notif.summary.length > 0 ? root.notif.summary : root.notif.appName
            font.pixelSize: Looks.font.size.medium
            emphasized: true
            color: Looks.colors.primary
            elide: Text.ElideRight
        }

        MText {
            width: parent.width
            text: root.notif.body
            font.pixelSize: Looks.font.size.medium
            color: Looks.colors.primary
            wrapMode: Text.Wrap
            maximumLineCount: root.maximumBodyLines
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                root.dismissed();
            else
                root.activated();
        }
    }

    MouseArea {
        id: replyField

        visible: root.replyReveal > 0
        opacity: root.replyReveal
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 14
            rightMargin: 14
            bottomMargin: 12
        }
        height: 32

        onClicked: replyInput.forceActiveFocus()

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Looks.colors.quaternary
            antialiasing: true
        }

        TextInput {
            id: replyInput
            anchors {
                left: parent.left
                right: sendButton.left
                leftMargin: 14
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            font.family: Looks.font.text
            font.pixelSize: Looks.font.size.medium
            color: Looks.colors.primary
            selectByMouse: true
            clip: true
            onAccepted: root.sendReply()
            Keys.onEscapePressed: {
                replyInput.text = "";
                replyInput.focus = false;
            }

            MText {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: replyInput.text.length === 0
                text: root.notif.inlineReplyPlaceholder.length > 0 ? root.notif.inlineReplyPlaceholder : "Reply"
                font.pixelSize: Looks.font.size.medium
                color: Looks.colors.tertiary
            }
        }

        Rectangle {
            id: sendButton
            anchors {
                right: parent.right
                rightMargin: 4
                verticalCenter: parent.verticalCenter
            }
            width: 24
            height: 24
            radius: width / 2
            color: replyInput.text.length > 0 ? Looks.accent : Looks.colors.quaternary
            antialiasing: true

            MaterialSymbol {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "arrow_upward"
                iconSize: 15
                color: replyInput.text.length > 0 ? "#ffffff" : Looks.colors.tertiary
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.sendReply()
            }
        }
    }

    Rectangle {
        id: closeButton
        anchors {
            right: parent.right
            rightMargin: 13
            top: stampLabel.top
            topMargin: -3
        }
        width: 20
        height: 20
        radius: width / 2
        color: closeArea.containsMouse ? Looks.colors.tertiary : Looks.colors.quaternary
        antialiasing: true
        opacity: root.hovered ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        MaterialSymbol {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "close"
            iconSize: 13
            color: Looks.colors.primary
        }

        MouseArea {
            id: closeArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closed()
        }
    }
}
