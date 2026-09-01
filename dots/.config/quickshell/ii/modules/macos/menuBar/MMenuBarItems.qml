pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.models.quickToggles
import qs.modules.common.widgets
import qs.modules.macos.items
import qs.modules.macos.looks

Row {
    id: root

    property bool editMode: false
    property string activeItem: ""
    signal expandRequested(string id)

    required property real dragOriginX
    required property real dragOriginY
    required property string screenName

    readonly property var storedItems: Config.options?.macos.menuBar.items ?? []

    // While dragging over the bar, it lays out as if the drop already happened. The
    // dragged entry is never taken out of a list mid-drag: that would destroy the
    // delegate holding the mouse grab and strand the drag.
    readonly property var items: {
        if (MDrag.active && MDrag.screenName === root.screenName && MDrag.targetList === "menuBar")
            return MItems.withInserted(root.storedItems, MDrag.itemId, MDrag.targetIndex);
        return root.storedItems;
    }

    // A handler rather than a binding: the layout it measures is itself driven by the
    // target it writes, which as a binding is a loop QML refuses to re-evaluate.
    Connections {
        target: MDrag

        function onPositionChanged() {
            root.updateDropTarget();
        }

        function onActiveChanged() {
            root.updateDropTarget();
        }
    }

    function updateDropTarget() {
        // A drag on another screen belongs to that screen's panels; clearing the target
        // here would wipe theirs on every pointer move.
        if (!MDrag.active || MDrag.screenName !== root.screenName)
            return;

        const localY = MDrag.position.y - root.dragOriginY;
        if (!root.editMode || localY < 0 || localY > Looks.sizes.menuBarHeight) {
            MDrag.releaseTarget("menuBar");
            return;
        }

        const localX = MDrag.position.x - root.dragOriginX;

        // Over its own slot the item keeps the place it already has, so a grab or a
        // small wobble never reshuffles the bar.
        for (const slot of root.children) {
            if (slot.modelData !== MDrag.itemId)
                continue;
            const left = slot.mapToItem(null, 0, 0).x;
            if (localX >= left && localX < left + slot.width)
                return;
        }

        MDrag.setTarget("menuBar", root.insertionIndex(localX));
    }

    // In window coordinates, not row coordinates: the row is anchored to the right, so
    // showing the dragged item moves the row's own origin and a cursor measured against
    // it would jump by the item's width.
    function insertionIndex(windowX: real): int {
        const shown = {};
        const slots = [];
        for (const slot of root.children) {
            if ((slot.itemIndex ?? -1) < 0)
                continue;
            shown[slot.modelData] = slot.visible;
            if (slot.visible && slot.modelData !== MDrag.itemId)
                slots.push(slot);
        }
        slots.sort((first, second) => first.x - second.x);

        let passed = 0;
        for (const slot of slots) {
            if (windowX < slot.mapToItem(null, 0, 0).x + slot.width / 2)
                break;
            passed++;
        }

        // An entry with nothing to show, a battery on a desktop say, still holds a place
        // in the list, so the number of slots the cursor passed is not a list index.
        const rest = root.items.filter(id => id !== MDrag.itemId);
        let position = 0;
        let seen = 0;
        while (position < rest.length && seen < passed) {
            if (shown[rest[position]] !== false)
                seen++;
            position++;
        }
        return position;
    }

    spacing: Looks.sizes.menuBarItemSpacing

    function componentFor(id: string): Component {
        switch (id) {
        case "spaces":
            return spacesItem;
        case "tray":
            return trayItem;
        case "battery":
            return batteryItem;
        case "wifi":
            return wifiItem;
        case "wired":
            return wiredItem;
        case "wireGuard":
            return wireGuardItem;
        case "cloudflareWarp":
            return cloudflareWarpItem;
        case "easyEffects":
            return easyEffectsItem;
        case "powerProfile":
            return powerProfileItem;
        case "notifications":
            return notificationsItem;
        case "onScreenKeyboard":
            return onScreenKeyboardItem;
        case "bluetooth":
            return bluetoothItem;
        case "volume":
            return volumeItem;
        case "brightness":
            return brightnessItem;
        case "media":
            return mediaItem;
        case "darkMode":
            return darkModeItem;
        case "nightLight":
            return nightLightItem;
        case "mic":
            return micItem;
        case "screenSnip":
            return screenSnipItem;
        case "colorPicker":
            return colorPickerItem;
        case "idleInhibitor":
            return idleInhibitorItem;
        }
        return null;
    }

    Component {
        id: spacesItem
        MMenuBarWorkspaces {}
    }

    Component {
        id: trayItem
        MMenuBarTray {}
    }

    Component {
        id: batteryItem
        MMenuBarItem {
            shown: Battery.available
            interactive: false

            MText {
                anchors.verticalCenter: parent.verticalCenter
                text: `${Math.round(Battery.percentage * 100)}%`
                color: Looks.colors.primary
                font.pixelSize: Looks.font.size.small
            }

            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                text: Battery.isCharging ? "battery_charging_full" : "battery_full"
                iconSize: 18
                color: Battery.isLowAndNotCharging ? Looks.colors.red : Looks.colors.primary
            }
        }
    }

    Component {
        id: wifiItem
        MMenuBarStatus {
            settingsCommand: Config.options.apps.network
            toggleModel: WifiToggle {}
        }
    }

    Component {
        id: wiredItem
        MMenuBarStatus {
            settingsCommand: Config.options.apps.networkEthernet
            toggleModel: EthernetToggle {}
        }
    }

    Component {
        id: wireGuardItem
        MMenuBarStatus {
            toggleModel: WireGuardToggle {}
        }
    }

    Component {
        id: cloudflareWarpItem
        MMenuBarStatus {
            toggleModel: CloudflareWarpToggle {}
        }
    }

    Component {
        id: easyEffectsItem
        MMenuBarStatus {
            toggleModel: EasyEffectsToggle {}
        }
    }

    Component {
        id: powerProfileItem
        MMenuBarStatus {
            toggleModel: PowerProfilesToggle {}
        }
    }

    Component {
        id: notificationsItem
        MMenuBarStatus {
            toggleModel: NotificationToggle {}
        }
    }

    Component {
        id: onScreenKeyboardItem
        MMenuBarStatus {
            toggleModel: OnScreenKeyboardToggle {}
        }
    }

    Component {
        id: bluetoothItem
        MMenuBarStatus {
            settingsCommand: Config.options.apps.bluetooth
            toggleModel: BluetoothToggle {}
        }
    }

    Component {
        id: volumeItem
        MMenuBarStatus {
            settingsCommand: Config.options.apps.volumeMixer
            toggleModel: AudioToggle {}
        }
    }

    Component {
        id: micItem
        MMenuBarStatus {
            settingsCommand: Config.options.apps.volumeMixer
            toggleModel: MicToggle {}
        }
    }

    Component {
        id: darkModeItem
        MMenuBarStatus {
            toggleModel: DarkModeToggle {}
        }
    }

    Component {
        id: nightLightItem
        MMenuBarStatus {
            toggleModel: NightLightToggle {}
        }
    }

    Component {
        id: screenSnipItem
        MMenuBarStatus {
            toggleModel: ScreenSnipToggle {}
        }
    }

    Component {
        id: colorPickerItem
        MMenuBarStatus {
            toggleModel: ColorPickerToggle {}
        }
    }

    Component {
        id: idleInhibitorItem
        MMenuBarStatus {
            toggleModel: IdleInhibitorToggle {}
        }
    }

    Component {
        id: brightnessItem
        MMenuBarItem {
            minWidth: 30
            horizontalPadding: 5
            onClicked: Quickshell.execDetached(["bash", "-c", Config.options.apps.display])

            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                text: "brightness_high"
                iconSize: 18
                color: Looks.colors.primary
            }
        }
    }

    Component {
        id: mediaItem
        MMenuBarItem {
            minWidth: 30
            horizontalPadding: 5
            shown: MprisController.currentPlayer !== null
            active: root.activeItem === "media"
            onClicked: root.expandRequested("media")

            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                text: MprisController.currentPlayer?.isPlaying ? "graphic_eq" : "pause"
                iconSize: 18
                color: Looks.colors.primary
            }
        }
    }

    Repeater {
        // Reordering must move delegates, not rebuild them: rebuilding destroys the
        // slot holding the mouse grab and the drag dies.
        model: ScriptModel {
            values: root.items
        }

        Item {
            id: slot

            required property string modelData
            required property int index

            readonly property int itemIndex: index
            readonly property bool dragged: MDrag.active && MDrag.itemId === slot.modelData

            implicitWidth: itemLoader.implicitWidth
            implicitHeight: Looks.sizes.menuBarHeight
            visible: itemLoader.item?.shown ?? true

            Loader {
                id: itemLoader
                height: parent.height
                opacity: slot.dragged ? 0.3 : 1
                sourceComponent: root.componentFor(slot.modelData)
            }

            MouseArea {
                id: dragArea

                property point pressPoint
                property bool dragging: false

                anchors.fill: parent
                enabled: root.editMode
                cursorShape: Qt.PointingHandCursor

                onPressed: event => {
                    dragArea.pressPoint = Qt.point(event.x, event.y);
                    dragArea.dragging = false;
                }

                onPositionChanged: event => {
                    const global = slot.mapToItem(null, event.x, event.y);
                    if (!dragArea.dragging && Math.hypot(event.x - dragArea.pressPoint.x, event.y - dragArea.pressPoint.y) > MDrag.threshold) {
                        dragArea.dragging = true;
                        MDrag.begin(slot.modelData, "menuBar", root.screenName, global.x + root.dragOriginX, global.y + root.dragOriginY);
                        // Start out where the item already is, so grabbing it moves nothing.
                        MDrag.setTarget("menuBar", slot.itemIndex);
                    }
                    if (dragArea.dragging)
                        MDrag.moveTo(global.x + root.dragOriginX, global.y + root.dragOriginY);
                }

                onReleased: {
                    if (dragArea.dragging) {
                        dragArea.dragging = false;
                        MDrag.drop();
                        return;
                    }
                    Config.options.macos.menuBar.items = MItems.withToggled(Config.options.macos.menuBar.items, slot.modelData);
                }

                onCanceled: {
                    if (dragArea.dragging) {
                        dragArea.dragging = false;
                        MDrag.cancel();
                    }
                }

                onWheel: event => {
                    Config.options.macos.menuBar.items = MItems.withMoved(Config.options.macos.menuBar.items, slot.modelData, event.angleDelta.y < 0 ? 1 : -1);
                    event.accepted = true;
                }
            }
        }
    }
}
