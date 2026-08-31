pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services
import qs.modules.macos.looks

MGlass {
    id: root

    required property var notif
    property int maximumBodyLines: 3

    signal activated
    signal dismissed

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

    implicitHeight: Math.max(64, textColumn.implicitHeight + 26)

    ClippingRectangle {
        id: icon
        anchors {
            left: parent.left
            leftMargin: 16
            verticalCenter: parent.verticalCenter
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
    }

    Column {
        id: textColumn
        anchors {
            left: icon.right
            leftMargin: 12
            right: stampLabel.left
            rightMargin: 8
            verticalCenter: parent.verticalCenter
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
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: event => {
            if (event.button === Qt.MiddleButton)
                root.dismissed();
            else
                root.activated();
        }
    }
}
