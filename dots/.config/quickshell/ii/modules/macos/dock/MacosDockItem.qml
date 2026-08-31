pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.macos.looks

Item {
    id: root

    required property var entry
    required property var slot
    required property real indicatorArea
    required property real capsuleHeight
    required property var dock
    required property int itemIndex

    readonly property bool isSeparator: slot.separator
    readonly property int windowCount: entry.toplevels.length
    readonly property bool active: entry.toplevels.some(t => t?.activated === true)
    readonly property bool dragged: dock.dragIndex === root.itemIndex
    property int lastFocused: -1

    x: dragged ? dock.dragX - width / 2 : slot.x
    y: parent.height - height
    width: slot.size
    height: slot.size
    z: dragged ? 1 : 0
    opacity: dragged ? 0.85 : 1

    Behavior on x {
        enabled: !root.dragged
        NumberAnimation {
            duration: Looks.animation.fast
            easing.type: Easing.OutQuad
        }
    }
    Behavior on width {
        NumberAnimation {
            duration: Looks.animation.fast
            easing.type: Easing.OutQuad
        }
    }

    Rectangle {
        visible: root.isSeparator
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height + root.indicatorArea - root.capsuleHeight + Looks.sizes.dockSeparatorInset
        width: 1
        height: root.capsuleHeight - Looks.sizes.dockSeparatorInset * 2
        color: Looks.colors.tertiary
    }

    ClippingRectangle {
        visible: !root.isSeparator
        anchors.fill: parent
        radius: Looks.sizes.dockIconRadius
        color: "transparent"
        antialiasing: true

        IconImage {
            anchors.fill: parent
            source: Quickshell.iconPath(AppSearch.guessIcon(root.entry.appId), "image-missing")
            smooth: true
        }
    }

    Rectangle {
        visible: !root.isSeparator && root.windowCount > 0
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height + Looks.sizes.dockIndicatorGap
        width: Looks.sizes.dockIndicatorSize
        height: Looks.sizes.dockIndicatorSize
        radius: height / 2
        color: root.active ? Looks.colors.primary : Looks.colors.secondary
    }

    MouseArea {
        id: mouseArea
        enabled: !root.isSeparator
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: root.dragged ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        hoverEnabled: true

        property real pressX: 0
        property bool moved: false

        onEntered: root.dock.setHover(root.entry, root.mapToItem(root.dock.contentItem, root.width / 2, 0).x)

        onExited: root.dock.clearHover(root.entry)

        onPressed: event => {
            pressX = event.x;
            moved = false;
        }

        onPositionChanged: event => {
            if (!pressed || event.buttons !== Qt.LeftButton)
                return;
            if (!moved && Math.abs(event.x - pressX) < 8)
                return;
            if (!moved) {
                moved = true;
                root.dock.beginDrag(root.itemIndex);
            }
            root.dock.updateDrag(mapToItem(root.parent, event.x, 0).x);
        }

        onReleased: {
            if (moved)
                root.dock.commitDrag();
            moved = false;
        }

        onCanceled: {
            root.dock.cancelDrag();
            moved = false;
        }

        onClicked: event => {
            if (moved)
                return;
            if (event.button === Qt.RightButton) {
                TaskbarApps.togglePin(root.dock.pinnableId(root.entry));
                return;
            }
            const desktopEntry = DesktopEntries.heuristicLookup(root.entry.appId);
            if (event.button === Qt.MiddleButton || root.windowCount === 0) {
                desktopEntry?.execute();
                return;
            }
            root.lastFocused = (root.lastFocused + 1) % root.windowCount;
            root.entry.toplevels[root.lastFocused].activate();
        }
    }
}
