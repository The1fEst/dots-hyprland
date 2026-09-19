import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

import qs.modules.ii.sidebarRight.quickToggles.androidStyle

AbstractQuickPanel {
    id: root
    property bool editMode: false
    Layout.fillWidth: true

    // Sizes
    implicitHeight: (editMode ? contentItem.implicitHeight : usedRows.implicitHeight) + root.padding * 2
    Behavior on implicitHeight {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }
    property real spacing: 6
    property real padding: 6
    readonly property real baseCellWidth: {
        // This is the wrong calculation, but it looks correct in reality???
        // (theoretically spacing should be multiplied by 1 column less)
        const availableWidth = root.width - (root.padding * 2) - (root.spacing * (root.columns))
        return availableWidth / root.columns
    }
    readonly property real baseCellHeight: 56

    // Toggles
    readonly property list<string> availableToggleTypes: ["network", "bluetooth", "idleInhibitor", "easyEffects", "nightLight", "darkMode", "cloudflareWarp", "wireGuard", "screenSnip", "colorPicker", "onScreenKeyboard", "mic", "audio", "notifications", "powerProfile"]
    readonly property int columns: Config.options.sidebar.quickToggles.android.columns
    readonly property list<var> storedToggles: Config.ready ? Config.options.sidebar.quickToggles.android.toggles : []
    readonly property list<var> toggles: (QuickToggleDrag.active && QuickToggleDrag.targetList === "used") ? QuickToggleDrag.withInserted(root.storedToggles, QuickToggleDrag.type, QuickToggleDrag.targetIndex) : root.storedToggles
    readonly property list<var> toggleRows: toggleRowsForList(toggles)
    readonly property list<var> unusedToggles: {
        const types = availableToggleTypes.filter(type => !root.storedToggles.some(toggle => (toggle && toggle.type === type)))
        return types.map(type => { return { type: type, size: 1 } })
    }
    readonly property list<var> unusedToggleRows: toggleRowsForList(unusedToggles)

    Connections {
        target: QuickToggleDrag

        function onPositionChanged() {
            root.updateDropTarget();
        }

        function onActiveChanged() {
            root.updateDropTarget();
        }
    }

    function cellsIn(container: var): var {
        const cells = [];
        for (const row of (container?.children ?? [])) {
            for (const cell of (row.groupData ?? [])) {
                if (cell.buttonData !== undefined)
                    cells.push(cell);
            }
        }
        return cells;
    }

    function usedCells(): var {
        return root.cellsIn(usedRows);
    }

    function cellTypeAt(item: Item, x: real, y: real): string {
        for (const cell of [...root.usedCells(), ...root.cellsIn(unusedSection.item)]) {
            const point = cell.mapFromItem(item, x, y);
            if (point.x >= 0 && point.y >= 0 && point.x < cell.width && point.y < cell.height)
                return cell.buttonData?.type ?? "";
        }
        return "";
    }

    function toggleSize(type: string): void {
        const toggleList = Config.options.sidebar.quickToggles.android.toggles;
        const index = (toggleList ?? []).findIndex(toggle => toggle && toggle.type === type);
        if (index === -1)
            return;
        toggleList[index].size = 3 - toggleList[index].size;
    }

    function updateDropTarget(): void {
        if (!QuickToggleDrag.active)
            return;
        if (!root.editMode) {
            QuickToggleDrag.releaseTarget();
            return;
        }

        const usedPoint = usedRows.mapFromItem(null, QuickToggleDrag.position.x, QuickToggleDrag.position.y);
        if (usedPoint.x >= 0 && usedPoint.y >= 0 && usedPoint.x <= usedRows.width && usedPoint.y <= usedRows.height) {
            for (const cell of root.usedCells()) {
                if (cell.buttonData?.type !== QuickToggleDrag.type)
                    continue;
                const origin = usedRows.mapFromItem(cell, 0, 0);
                if (usedPoint.x >= origin.x && usedPoint.x < origin.x + cell.width && usedPoint.y >= origin.y && usedPoint.y < origin.y + cell.height)
                    return;
            }
            QuickToggleDrag.setTarget("used", root.insertionIndex(usedPoint));
            return;
        }

        const unusedPoint = unusedSection.mapFromItem(null, QuickToggleDrag.position.x, QuickToggleDrag.position.y);
        if (unusedSection.visible && unusedPoint.x >= 0 && unusedPoint.y >= 0 && unusedPoint.x <= unusedSection.width && unusedPoint.y <= unusedSection.height) {
            QuickToggleDrag.setTarget("unused", -1);
            return;
        }

        QuickToggleDrag.releaseTarget();
    }

    function insertionIndex(point: point): int {
        const cells = root.usedCells().filter(cell => cell.buttonData?.type !== QuickToggleDrag.type).map(cell => {
            const origin = usedRows.mapFromItem(cell, 0, 0);
            return {
                x: origin.x,
                y: origin.y,
                width: cell.width,
                height: cell.height
            };
        });
        cells.sort((first, second) => (first.y - second.y) || (first.x - second.x));

        const step = root.baseCellHeight + root.spacing;
        const pointRow = Math.floor(point.y / step);

        let index = 0;
        for (const cell of cells) {
            const cellRow = Math.round(cell.y / step);
            if (pointRow < cellRow)
                break;
            if (pointRow === cellRow) {
                const fillsRow = cell.width >= usedRows.width - 1;
                const passed = fillsRow ? point.y >= cell.y + cell.height / 2 : point.x >= cell.x + cell.width / 2;
                if (!passed)
                    break;
            }
            index++;
        }
        return index;
    }

    function toggleRowsForList(togglesList) {
        var rows = [];
        var row = [];
        var totalSize = 0; // Total cols taken in current row
        for (var i = 0; i < togglesList.length; i++) {
            if (!togglesList[i]) continue;
            if (totalSize + togglesList[i].size > columns) {
                rows.push(row);
                row = [];
                totalSize = 0;
            }
            row.push(togglesList[i]);
            totalSize += togglesList[i].size;
        }
        if (row.length > 0) {
            rows.push(row);
        }
        return rows;
    }

    Column {
        id: contentItem
        anchors {
            fill: parent
            margins: root.padding
        }
        spacing: 12
        
        Column {
            id: usedRows
            spacing: root.spacing

            Repeater {
                id: usedRowsRepeater
                model: ScriptModel {
                    values: Array(root.toggleRows.length)
                }
                delegate: ButtonGroup {
                    id: toggleRow
                    required property int index
                    property var modelData: root.toggleRows[index]
                    spacing: root.spacing

                    Repeater {
                        model: ScriptModel {
                            values: toggleRow?.modelData ?? []
                            objectProp: "type"
                        }
                        delegate: AndroidToggleDelegateChooser {
                            editMode: root.editMode
                            baseCellWidth: root.baseCellWidth
                            baseCellHeight: root.baseCellHeight
                            spacing: root.spacing
                            onOpenAudioOutputDialog: root.openAudioOutputDialog()
                            onOpenAudioInputDialog: root.openAudioInputDialog()
                            onOpenBluetoothDialog: root.openBluetoothDialog()
                            onOpenNightLightDialog: root.openNightLightDialog()
                            onOpenWifiDialog: root.openWifiDialog()
                            onOpenWireGuardDialog: root.openWireGuardDialog()
                        }
                    }
                }
            }
        }

        FadeLoader {
            shown: root.editMode
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: root.baseCellHeight / 2
                rightMargin: root.baseCellHeight / 2
            }
            sourceComponent: Rectangle {
                implicitHeight: 1
                color: Appearance.colors.colOutlineVariant
            }
        }

        FadeLoader {
            id: unusedSection
            shown: root.editMode
            sourceComponent: Column {
                id: unusedRows
                spacing: root.spacing

                Repeater {
                    model: ScriptModel {
                        values: Array(root.unusedToggleRows.length)
                    }
                    delegate: ButtonGroup {
                        id: unusedToggleRow
                        required property int index
                        property var modelData: root.unusedToggleRows[index]
                        spacing: root.spacing

                        Repeater {
                            model: ScriptModel {
                                values: unusedToggleRow?.modelData ?? []
                                objectProp: "type"
                            }
                            delegate: AndroidToggleDelegateChooser {
                                editMode: root.editMode
                                baseCellWidth: root.baseCellWidth
                                baseCellHeight: root.baseCellHeight
                                spacing: root.spacing
                            }
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        id: editInteraction
        anchors.fill: parent
        visible: root.editMode
        enabled: root.editMode
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        property point pressPoint
        property string pressedType: ""
        property bool dragging: false

        function finish(): void {
            editInteraction.dragging = false;
            editInteraction.pressedType = "";
        }

        onPressed: event => {
            editInteraction.pressPoint = Qt.point(event.x, event.y);
            editInteraction.pressedType = root.cellTypeAt(editInteraction, event.x, event.y);
            editInteraction.dragging = false;
            if (event.button === Qt.RightButton)
                root.toggleSize(editInteraction.pressedType);
        }
        onPositionChanged: event => {
            if (!(event.buttons & Qt.LeftButton) || editInteraction.pressedType.length === 0)
                return;
            const global = editInteraction.mapToItem(null, event.x, event.y);
            if (!editInteraction.dragging && Math.hypot(event.x - editInteraction.pressPoint.x, event.y - editInteraction.pressPoint.y) > QuickToggleDrag.threshold) {
                editInteraction.dragging = true;
                QuickToggleDrag.begin(editInteraction.pressedType, global.x, global.y);
            }
            if (editInteraction.dragging)
                QuickToggleDrag.moveTo(global.x, global.y);
        }
        onReleased: event => {
            if (event.button !== Qt.LeftButton)
                return;
            if (editInteraction.dragging)
                QuickToggleDrag.drop();
            editInteraction.finish();
        }
        onCanceled: {
            if (editInteraction.dragging)
                QuickToggleDrag.cancel();
            editInteraction.finish();
        }
        onPressAndHold: {
            if (!editInteraction.dragging)
                root.toggleSize(editInteraction.pressedType);
        }
    }
}
