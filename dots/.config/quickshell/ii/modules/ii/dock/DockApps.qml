pragma ComponentBehavior: Bound
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item {
    id: root
    property real maxWindowPreviewHeight: 200
    property real maxWindowPreviewWidth: 300
    property real windowControlsHeight: 30
    property real buttonPadding: 5

    property Item lastHoveredButton: null
    property bool buttonHovered: false
    property bool requestDockShow: previewPopup.show

    Layout.fillHeight: true
    Layout.topMargin: Appearance.sizes.hyprlandGapsOut
    implicitWidth: appRow.implicitWidth

    readonly property list<var> apps: TaskbarApps.apps
    readonly property real spacing: 2

    property bool dragging: false
    property int dragIndex: -1
    property int dropIndex: -1
    property real dragX: 0

    onAppsChanged: if (!root.dragging) root.cancelDrag()

    readonly property var restOrder: {
        const rest = [];
        for (let i = 0; i < root.apps.length; i++) {
            if (i !== root.dragIndex)
                rest.push(i);
        }
        return rest;
    }

    readonly property var order: {
        if (root.dragIndex < 0 || root.dropIndex < 0)
            return [...Array(root.apps.length).keys()];
        const arranged = [...root.restOrder];
        arranged.splice(Math.min(root.dropIndex, arranged.length), 0, root.dragIndex);
        return arranged;
    }

    readonly property var layout: {
        const positions = new Array(root.apps.length).fill(0);
        if (appRepeater.count < root.apps.length)
            return {
                positions: positions,
                width: 0
            };
        let cursor = 0;
        for (const index of root.order) {
            positions[index] = cursor;
            cursor += (appRepeater.itemAt(index)?.implicitWidth ?? 0) + root.spacing;
        }
        return {
            positions: positions,
            width: Math.max(0, cursor - root.spacing)
        };
    }

    function dropPositionFor(x: real): int {
        let position = 0;
        let acc = 0;
        for (const index of root.restOrder) {
            const slot = appRepeater.itemAt(index)?.implicitWidth ?? 0;
            if (x < acc + slot / 2)
                break;
            acc += slot + root.spacing;
            position++;
        }
        return position;
    }

    function beginDrag(index: int): void {
        root.dragging = true;
        root.dragIndex = index;
        root.dropIndex = -1;
    }

    function updateDrag(rowX: real): void {
        root.dragX = rowX;
        root.dropIndex = root.dropPositionFor(rowX);
    }

    function cancelDrag(): void {
        root.dragging = false;
        root.dragIndex = -1;
        root.dropIndex = -1;
    }

    function pinnableId(entry: var): string {
        return entry.toplevels[0]?.appId ?? entry.appId;
    }

    function commitDrag(): void {
        if (root.dragIndex < 0 || root.dropIndex < 0) {
            root.cancelDrag();
            return;
        }
        const arranged = root.order;
        const separatorAt = arranged.findIndex(index => root.apps[index].appId === "SEPARATOR");
        if (separatorAt < 0) {
            root.cancelDrag();
            return;
        }
        const pinned = [];
        for (let position = 0; position < separatorAt; position++) {
            pinned.push(root.pinnableId(root.apps[arranged[position]]));
        }
        const current = Config.options.dock.pinnedApps ?? [];
        if (pinned.length === current.length && pinned.every((appId, position) => appId === current[position])) {
            root.cancelDrag();
            return;
        }
        root.dragging = false;
        Config.options.dock.pinnedApps = pinned;
    }

    function popupCenterXForButton(button) {
        if (!button || !root.QsWindow)
            return 0;
        return root.QsWindow.mapFromItem(button, button.width / 2, 0).x;
    }

    Item {
        id: appRow
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        implicitWidth: root.layout.width

        Behavior on implicitWidth {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        Repeater {
            id: appRepeater
            model: ScriptModel {
                objectProp: "appId"
                values: root.apps
            }
            delegate: DockAppButton {
                required property var modelData
                required property int index
                appToplevel: modelData
                appListRoot: root
                itemIndex: index

                topInset: Appearance.sizes.hyprlandGapsOut + root.buttonPadding
                bottomInset: Appearance.sizes.hyprlandGapsOut + root.buttonPadding
            }
        }
    }

    PopupWindow {
        id: previewPopup
        property var appTopLevel: root.lastHoveredButton?.appToplevel

        property bool shouldShow: (popupMouseArea.containsMouse || root.buttonHovered) && appTopLevel && appTopLevel.toplevels && appTopLevel.toplevels.length > 0

        property bool show: false
        property real cachedCenterX: 0

        Connections {
            target: root
            function onLastHoveredButtonChanged() {
                if (root.lastHoveredButton && root.QsWindow)
                    previewPopup.cachedCenterX = root.popupCenterXForButton(root.lastHoveredButton);
            }
            function onButtonHoveredChanged() {
                if (root.buttonHovered && root.lastHoveredButton && root.QsWindow)
                    previewPopup.cachedCenterX = root.popupCenterXForButton(root.lastHoveredButton);
                updateTimer.restart();
            }
        }

        onShouldShowChanged: {
            updateTimer.restart();
        }

        Timer {
            id: updateTimer
            interval: 100
            onTriggered: {
                previewPopup.show = previewPopup.shouldShow;
            }
        }

        anchor {
            window: root.QsWindow.window
            adjustment: PopupAdjustment.None
            gravity: Edges.Top | Edges.Right
            edges: Edges.Top | Edges.Left
        }

        visible: popupBackground.opacity > 0
        color: "transparent"
        implicitWidth: root.QsWindow.window?.width ?? 1
        implicitHeight: popupMouseArea.implicitHeight + root.windowControlsHeight + Appearance.sizes.elevationMargin * 2

        MouseArea {
            id: popupMouseArea
            anchors.bottom: parent.bottom
            implicitWidth: popupBackground.implicitWidth + Appearance.sizes.elevationMargin * 2
            implicitHeight: root.maxWindowPreviewHeight + root.windowControlsHeight + Appearance.sizes.elevationMargin * 2
            hoverEnabled: true
            x: previewPopup.cachedCenterX - width / 2

            StyledRectangularShadow {
                target: popupBackground
                opacity: previewPopup.show ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }

            Rectangle {
                id: popupBackground
                property real padding: 5
                opacity: previewPopup.show ? 1 : 0
                visible: opacity > 0
                Behavior on opacity {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                clip: true
                color: Appearance.m3colors.m3surfaceContainer
                radius: Appearance.rounding.normal
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Appearance.sizes.elevationMargin
                anchors.horizontalCenter: parent.horizontalCenter
                implicitHeight: previewRowLayout.implicitHeight + padding * 2
                implicitWidth: previewRowLayout.implicitWidth + padding * 2
                Behavior on implicitWidth {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                Behavior on implicitHeight {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }

                RowLayout {
                    id: previewRowLayout
                    anchors.centerIn: parent
                    Repeater {
                        model: ScriptModel {
                            values: previewPopup.appTopLevel?.toplevels ?? []
                        }
                        RippleButton {
                            id: windowButton
                            Layout.fillHeight: true
                            required property var modelData
                            padding: 0
                            middleClickAction: () => {
                                windowButton.modelData?.close();
                            }
                            onClicked: {
                                windowButton.modelData?.activate();
                            }
                            contentItem: ColumnLayout {
                                implicitWidth: screencopyView.implicitWidth
                                implicitHeight: screencopyView.implicitHeight

                                ButtonGroup {
                                    contentWidth: parent.width - anchors.margins * 2
                                    StyledText {
                                        Layout.margins: 5
                                        Layout.fillWidth: true
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        text: windowButton.modelData?.title
                                        elide: Text.ElideRight
                                        color: Appearance.m3colors.m3onSurface
                                    }
                                    GroupButton {
                                        id: closeButton
                                        colBackground: ColorUtils.transparentize(Appearance.colors.colSurfaceContainer)
                                        baseWidth: root.windowControlsHeight
                                        baseHeight: root.windowControlsHeight
                                        buttonRadius: Appearance.rounding.full
                                        contentItem: MaterialSymbol {
                                            anchors.centerIn: parent
                                            horizontalAlignment: Text.AlignHCenter
                                            text: "close"
                                            iconSize: Appearance.font.pixelSize.normal
                                            color: Appearance.m3colors.m3onSurface
                                        }
                                        onClicked: {
                                            windowButton.modelData?.close();
                                        }
                                    }
                                }
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    implicitHeight: screencopyView.height
                                    implicitWidth: screencopyView.width
                                    ScreencopyView {
                                        id: screencopyView
                                        anchors.centerIn: parent
                                        captureSource: windowButton.modelData
                                        live: true
                                        paintCursor: true
                                        constraintSize: Qt.size(root.maxWindowPreviewWidth, root.maxWindowPreviewHeight)
                                        layer.enabled: true
                                        layer.effect: OpacityMask {
                                            maskSource: Rectangle {
                                                width: screencopyView.width
                                                height: screencopyView.height
                                                radius: Appearance.rounding.small
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
