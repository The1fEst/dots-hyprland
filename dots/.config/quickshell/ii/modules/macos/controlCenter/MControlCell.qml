pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.common
import qs.modules.macos.items
import qs.modules.macos.looks

Item {
    id: root

    required property string itemId
    required property bool editMode
    required property MGlassBackdrop backdrop
    required property real dragOriginX
    required property real dragOriginY
    required property string screenName
    property Component content: null
    property int itemIndex: -1

    signal sizeMenuRequested(point position)

    readonly property var info: MItems.info(root.itemId)
    readonly property bool inControlCenter: MItems.has(Config.options?.macos.controlCenter.controls, root.itemId)
    readonly property bool inMenuBar: MItems.has(Config.options?.macos.menuBar.items, root.itemId)
    readonly property real cellRadius: Looks.radiusFor(root.width, root.height)
    readonly property bool dragged: MDrag.active && MDrag.itemId === root.itemId

    function toggleControlCenter() {
        Config.options.macos.controlCenter.controls = MItems.withToggled(Config.options.macos.controlCenter.controls, root.itemId);
    }

    function toggleMenuBar() {
        Config.options.macos.menuBar.items = MItems.withToggled(Config.options.macos.menuBar.items, root.itemId);
    }

    Loader {
        anchors.fill: parent
        active: root.content !== null
        sourceComponent: root.content
        opacity: root.dragged ? 0.3 : !root.editMode || root.inControlCenter ? 1 : 0.5
    }

    MControlGhost {
        anchors.fill: parent
        visible: root.content === null
        backdrop: root.backdrop
        info: root.info
        opacity: root.dragged ? 0.3 : root.inMenuBar ? 1 : 0.5
    }

    MouseArea {
        id: dragArea

        property point pressPoint
        property bool dragging: false

        anchors.fill: parent
        enabled: root.editMode
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: event => {
            if (event.button === Qt.RightButton) {
                root.sizeMenuRequested(root.mapToItem(null, event.x, event.y));
                return;
            }
            dragArea.pressPoint = Qt.point(event.x, event.y);
            dragArea.dragging = false;
        }

        onPositionChanged: event => {
            const global = root.mapToItem(null, event.x, event.y);
            if (!dragArea.dragging && Math.hypot(event.x - dragArea.pressPoint.x, event.y - dragArea.pressPoint.y) > MDrag.threshold) {
                dragArea.dragging = true;
                MDrag.begin(root.itemId, root.inControlCenter ? "controlCenter" : "", root.screenName, global.x + root.dragOriginX, global.y + root.dragOriginY);
                // Start out where the item already is, so grabbing it moves nothing.
                if (root.inControlCenter)
                    MDrag.setTarget("controlCenter", root.itemIndex);
            }
            if (dragArea.dragging)
                MDrag.moveTo(global.x + root.dragOriginX, global.y + root.dragOriginY);
        }

        onReleased: event => {
            if (event.button === Qt.RightButton)
                return;
            if (dragArea.dragging) {
                dragArea.dragging = false;
                MDrag.drop();
                return;
            }
            if (root.info?.controlCenter)
                root.toggleControlCenter();
            else
                root.toggleMenuBar();
        }

        onCanceled: {
            if (dragArea.dragging) {
                dragArea.dragging = false;
                MDrag.cancel();
            }
        }

        onWheel: event => {
            if (root.inControlCenter)
                Config.options.macos.controlCenter.controls = MItems.withMoved(Config.options.macos.controlCenter.controls, root.itemId, event.angleDelta.y < 0 ? 1 : -1);
            else if (root.inMenuBar)
                Config.options.macos.menuBar.items = MItems.withMoved(Config.options.macos.menuBar.items, root.itemId, event.angleDelta.y < 0 ? 1 : -1);
            event.accepted = true;
        }
    }

}
