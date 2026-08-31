pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.macos.items
import qs.modules.macos.looks

PanelWindow {
    id: root

    required property var screenData
    property bool open: false
    property bool editMode: false
    property string expanded: ""

    signal editRequested
    signal expandRequested(string id)
    signal collapseRequested

    readonly property real sideMargin: 12
    readonly property real cellSpacing: 10
    readonly property int columns: 4
    readonly property real cellWidth: 70
    readonly property real cellHeight: 62

    readonly property var storedControls: Config.options?.macos.controlCenter.controls ?? []

    // While dragging over the grid, it lays out as if the drop already happened. The
    // dragged entry is never taken out of a list mid-drag: that would destroy the
    // delegate holding the mouse grab and strand the drag.
    readonly property var controls: {
        if (MDrag.active && MDrag.screenName === root.screenName && MDrag.targetList === "controlCenter")
            return MItems.withInserted(root.storedControls, MDrag.itemId, MDrag.targetIndex);
        return root.storedControls;
    }
    readonly property var extras: MItems.all.filter(item => !MItems.has(root.storedControls, item.id)).map(item => item.id)

    readonly property string screenName: screenData?.name ?? ""
    readonly property real dragOriginX: (screenData?.x ?? 0) + (screenData?.width ?? 0) - root.width
    readonly property real dragOriginY: (screenData?.y ?? 0) + Looks.sizes.menuBarHeight

    onEditModeChanged: sizeMenu.opened = false
    onOpenChanged: sizeMenu.opened = false

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

        if (!root.editMode) {
            MDrag.releaseTarget("controlCenter");
            return;
        }

        const localX = MDrag.position.x - root.dragOriginX;
        const localY = MDrag.position.y - root.dragOriginY;

        const gridPoint = grid.mapFromItem(null, localX, localY);
        if ((MItems.info(MDrag.itemId)?.controlCenter ?? false) && gridPoint.x >= 0 && gridPoint.y >= 0 && gridPoint.x <= grid.width && gridPoint.y <= grid.height) {
            // Over its own slot the item keeps the place it already has, so a grab or a
            // small wobble never reshuffles the grid.
            for (const cell of grid.children) {
                if (cell.itemId !== MDrag.itemId)
                    continue;
                if (gridPoint.x >= cell.x && gridPoint.x < cell.x + cell.width && gridPoint.y >= cell.y && gridPoint.y < cell.y + cell.height) {
                    return;
                }
            }
            MDrag.setTarget("controlCenter", root.insertionIndex(gridPoint));
            return;
        }

        const extrasPoint = extrasSection.mapFromItem(null, localX, localY);
        if (extrasSection.visible && extrasPoint.x >= 0 && extrasPoint.y >= 0 && extrasPoint.x <= extrasSection.width && extrasPoint.y <= extrasSection.height) {
            MDrag.setTarget("extras", -1);
            return;
        }

        MDrag.releaseTarget("controlCenter");
    }

    // Counts the cells that keep their place, so inserting the dragged one cannot
    // shift the answer back and forth under a still cursor.
    function insertionIndex(point: point): int {
        const cells = [];
        for (const cell of grid.children) {
            if ((cell.itemIndex ?? -1) < 0 || cell.itemId === MDrag.itemId)
                continue;
            cells.push(cell);
        }
        cells.sort((first, second) => (first.y - second.y) || (first.x - second.x));

        // Compared by the row a cell starts on, not by its rectangle: a two row tall
        // cell would otherwise swallow the row below it and cut the scan short.
        const step = root.cellHeight + root.cellSpacing;
        const pointRow = Math.floor(point.y / step);

        let index = 0;
        for (const cell of cells) {
            const cellRow = Math.round(cell.y / step);
            if (pointRow < cellRow)
                break;
            if (pointRow === cellRow) {
                // A cell filling the row has nothing to its left or right, so which side
                // of it the cursor is on is a question about height, not width.
                const fillsRow = cell.width >= grid.width - 1;
                const passed = fillsRow ? point.y >= cell.y + cell.height / 2 : point.x >= cell.x + cell.width / 2;
                if (!passed)
                    break;
            }
            index++;
        }
        return index;
    }

    function spanWidth(cols: int): real {
        return cols * root.cellWidth + (cols - 1) * root.cellSpacing;
    }

    function spanHeight(rows: int): real {
        return rows * root.cellHeight + (rows - 1) * root.cellSpacing;
    }

    function sizeFor(id: string): string {
        const item = MItems.info(id);
        if (!item)
            return "normal";
        const entry = (Config.options?.macos.controlCenter.sizes ?? []).find(stored => stored.startsWith(`${id}:`));
        const size = entry ? entry.slice(id.length + 1) : "";
        return MItems.sizeOptions(item).indexOf(size) !== -1 ? size : item.defaultSize;
    }

    function setSize(id: string, size: string) {
        const sizes = (Config.options.macos.controlCenter.sizes ?? []).filter(stored => !stored.startsWith(`${id}:`));
        sizes.push(`${id}:${size}`);
        Config.options.macos.controlCenter.sizes = sizes;
    }

    screen: screenData
    visible: open
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: columns * cellWidth + (columns - 1) * cellSpacing + sideMargin * 2
    WlrLayershell.namespace: "quickshell:macosControlCenter"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors {
        top: true
        right: true
        bottom: true
    }

    mask: Region {
        item: root.open ? (sizeMenu.opened ? contentRoot : root.expanded.length > 0 ? mediaDetail : content) : null
    }

    Item {
        id: contentRoot
        anchors.fill: parent

        MGlassBackdrop {
            id: backdrop
            screenX: (root.screen?.width ?? 0) - root.width
            screenY: Looks.sizes.menuBarHeight
            panelWidth: root.width
            panelHeight: root.height
            captureWindows: root.open
        }

        MControlCatalog {
            id: catalog
            backdrop: backdrop
            screenData: root.screenData
            onExpandRequested: id => root.expandRequested(id)
        }

        MouseArea {
            anchors.fill: parent
            z: 40
            visible: sizeMenu.opened
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onPressed: sizeMenu.opened = false
        }

        MSizeMenu {
            id: sizeMenu
            backdrop: backdrop
            onChosen: size => root.setSize(sizeMenu.itemId, size)
        }

        Item {
            id: panelArea
            anchors.fill: parent
            visible: root.open

            MMediaDetail {
                id: mediaDetail
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: root.sideMargin
                }
                visible: root.expanded === "media"
                backdrop: backdrop
                onClosed: root.collapseRequested()
            }

            Column {
                id: content
                visible: root.expanded.length === 0
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: root.sideMargin
                }
                spacing: root.cellSpacing

                GridLayout {
                    id: grid
                    width: parent.width
                    columns: root.columns
                    columnSpacing: root.cellSpacing
                    rowSpacing: root.cellSpacing

                    Repeater {
                        // Reordering must move delegates, not rebuild them: rebuilding
                        // destroys the cell holding the mouse grab and the drag dies.
                        model: ScriptModel {
                            values: root.controls
                        }

                        MControlCell {
                            id: usedCell
                            required property string modelData

                            required property int index

                            itemId: modelData
                            itemIndex: index
                            editMode: root.editMode
                            backdrop: backdrop
                            content: catalog.componentFor(modelData)
                            dragOriginX: root.dragOriginX
                            dragOriginY: root.dragOriginY
                            screenName: root.screenName
                            onSizeMenuRequested: position => sizeMenu.open(usedCell.itemId, root.sizeFor(usedCell.itemId), position)

                            readonly property var span: MItems.span(usedCell.info, root.sizeFor(usedCell.itemId))

                            Layout.columnSpan: usedCell.span[0]
                            Layout.rowSpan: usedCell.span[1]
                            Layout.preferredWidth: root.spanWidth(usedCell.span[0])
                            Layout.preferredHeight: root.spanHeight(usedCell.span[1])
                        }
                    }
                }

                Loader {
                    id: extrasSection
                    width: parent.width
                    visible: root.editMode
                    active: root.editMode

                    sourceComponent: Item {
                        implicitWidth: extrasSection.width
                        implicitHeight: extrasColumn.implicitHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -5
                            visible: MDrag.targetList === "extras"
                            radius: 14
                            color: "transparent"
                            border.width: 1
                            border.color: Looks.accent
                        }

                        Column {
                            id: extrasColumn
                            width: parent.width
                            spacing: root.cellSpacing

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Looks.colors.divider
                            }

                            GridLayout {
                                width: parent.width
                                columns: root.columns
                                columnSpacing: root.cellSpacing
                                rowSpacing: root.cellSpacing

                                Repeater {
                                    model: ScriptModel {
                                        values: root.extras
                                    }

                                    MControlCell {
                                        id: extraCell
                                        required property string modelData

                                        itemId: modelData
                                        editMode: root.editMode
                                        backdrop: backdrop
                                        dragOriginX: root.dragOriginX
                                        dragOriginY: root.dragOriginY
                                        screenName: root.screenName

                                        readonly property var span: MItems.span(extraCell.info, root.sizeFor(extraCell.itemId))

                                        Layout.columnSpan: extraCell.span[0]
                                        Layout.rowSpan: extraCell.span[1]
                                        Layout.preferredWidth: root.spanWidth(extraCell.span[0])
                                        Layout.preferredHeight: root.spanHeight(extraCell.span[1])
                                    }
                                }
                            }
                        }
                    }
                }

                MGlass {
                    id: editPill
                    anchors.horizontalCenter: parent.horizontalCenter
                    backdrop: backdrop
                    radius: height / 2
                    implicitWidth: pillLabel.implicitWidth + 45
                    implicitHeight: 28

                    MaterialSymbol {
                        id: pillIcon
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        text: root.editMode ? "check" : "edit"
                        iconSize: 15
                        color: Looks.colors.secondary
                    }

                    MText {
                        id: pillLabel
                        anchors {
                            left: pillIcon.right
                            leftMargin: 6
                            verticalCenter: parent.verticalCenter
                        }
                        text: root.editMode ? Translation.tr("Done") : Translation.tr("Edit Widgets")
                        font.pixelSize: Looks.font.size.small
                        color: Looks.colors.secondary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.editRequested()
                    }
                }
            }
        }
    }
}
