pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.macos.looks

Scope {
    id: root

    readonly property bool pinned: Config.options?.dock.pinnedOnStartup ?? false

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: dockWindow
            required property var modelData

            readonly property real base: Looks.sizes.dockIconSize
            readonly property real maxSize: Looks.sizes.dockIconMaxSize
            readonly property real padding: Looks.sizes.dockPaddingH
            readonly property real iconSpacing: Looks.sizes.dockIconSpacing
            readonly property real separatorWidth: Looks.sizes.dockSeparatorWidth
            readonly property real indicatorArea: Looks.sizes.dockIndicatorGap + Looks.sizes.dockIndicatorSize + Looks.sizes.dockIndicatorBottom
            readonly property real capsuleHeight: Looks.sizes.dockPaddingTop + base + indicatorArea
            readonly property real liftRoom: maxSize - base
            readonly property real bottomMargin: Looks.sizes.dockBottomMargin

            readonly property bool hoverToReveal: Config.options?.dock.hoverToReveal ?? false
            readonly property real hoverRegionHeight: Config.options?.dock.hoverRegionHeight ?? 2
            readonly property bool reveal: root.pinned || (hoverToReveal && dockMouseArea.containsMouse) || dockPreview.shown || !(ToplevelManager.activeToplevel?.activated ?? false)

            readonly property list<var> apps: TaskbarApps.apps

            property int dragIndex: -1
            property int dropIndex: -1
            property real dragX: 0

            property var hoverEntry: null
            property real hoverCenterX: 0

            function setHover(entry, centerX) {
                hoverEntry = entry;
                hoverCenterX = centerX;
            }

            function clearHover(entry) {
                if (hoverEntry === entry)
                    hoverEntry = null;
            }

            function slotWidth(index) {
                return apps[index].appId === "SEPARATOR" ? separatorWidth : base;
            }

            readonly property var restOrder: {
                const rest = [];
                for (let i = 0; i < apps.length; i++) {
                    if (i !== dragIndex)
                        rest.push(i);
                }
                return rest;
            }

            readonly property var order: {
                if (dragIndex < 0 || dropIndex < 0)
                    return restOrder.length === apps.length ? restOrder : [...Array(apps.length).keys()];
                const arranged = [...restOrder];
                arranged.splice(Math.min(dropIndex, arranged.length), 0, dragIndex);
                return arranged;
            }

            function dropPositionFor(x) {
                let position = 0;
                let acc = 0;
                for (const index of restOrder) {
                    const slot = slotWidth(index);
                    if (x < acc + slot / 2)
                        break;
                    acc += slot + iconSpacing;
                    position++;
                }
                return position;
            }

            function beginDrag(index) {
                dragIndex = index;
                dropIndex = -1;
            }

            function updateDrag(rowX) {
                dragX = rowX;
                dropIndex = dropPositionFor(rowX);
            }

            function cancelDrag() {
                dragIndex = -1;
                dropIndex = -1;
            }

            function pinnableId(entry) {
                return entry.toplevels[0]?.appId ?? entry.appId;
            }

            function commitDrag() {
                if (dragIndex < 0 || dropIndex < 0) {
                    cancelDrag();
                    return;
                }
                const arranged = order;
                const separatorAt = arranged.findIndex(i => apps[i].appId === "SEPARATOR");
                if (separatorAt >= 0) {
                    const pinned = [];
                    for (let position = 0; position < separatorAt; position++) {
                        pinned.push(pinnableId(apps[arranged[position]]));
                    }
                    Config.options.dock.pinnedApps = pinned;
                }
                cancelDrag();
            }

            readonly property real homeWidth: {
                let total = 0;
                for (let i = 0; i < apps.length; i++) {
                    total += slotWidth(i) + iconSpacing;
                }
                return Math.max(0, total - iconSpacing);
            }

            readonly property var layout: {
                const slots = new Array(apps.length);
                const influence = base * 2.2;
                let cursor = 0;
                let home = 0;
                for (const index of order) {
                    const separator = apps[index].appId === "SEPARATOR";
                    const slot = separator ? separatorWidth : base;
                    const center = home + slot / 2;
                    let size = slot;
                    if (!separator && dockMouseArea.magnifying) {
                        const dist = Math.abs(dockMouseArea.rowX - center);
                        if (dist < influence) {
                            const t = 1 - dist / influence;
                            size = base + (maxSize - base) * (t * t * (3 - 2 * t));
                        }
                    }
                    slots[index] = {
                        x: cursor,
                        size: size,
                        separator: separator
                    };
                    cursor += size + iconSpacing;
                    home += slot + iconSpacing;
                }
                return {
                    items: slots,
                    width: Math.max(0, cursor - iconSpacing)
                };
            }

            screen: modelData
            visible: !GlobalStates.screenLocked
            color: "transparent"
            exclusiveZone: root.pinned ? capsuleHeight + bottomMargin : 0
            WlrLayershell.namespace: "quickshell:macosDock"
            anchors {
                bottom: true
                left: true
                right: true
            }
            implicitHeight: capsuleHeight + liftRoom + bottomMargin + Looks.sizes.shadowMargin

            mask: Region {
                item: dockMouseArea
            }

            MacosDockPreview {
                id: dockPreview
                dock: dockWindow
            }

            MGlassBackdrop {
                id: dockBackdrop
                screenX: 0
                screenY: (dockWindow.screen?.height ?? 0) - dockWindow.height
                panelWidth: dockWindow.width
                panelHeight: dockWindow.height
            }

            MouseArea {
                id: dockMouseArea
                hoverEnabled: true
                acceptedButtons: Qt.NoButton

                readonly property bool magnifying: containsMouse && dockWindow.dragIndex < 0
                readonly property real rowX: mouseX - dockWindow.padding

                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                width: dockWindow.homeWidth + dockWindow.padding * 2
                height: dockWindow.reveal ? dockWindow.capsuleHeight + dockWindow.liftRoom + dockWindow.bottomMargin : dockWindow.hoverToReveal ? dockWindow.hoverRegionHeight : 0

                Item {
                    id: dockContent
                    width: parent.width
                    height: dockWindow.capsuleHeight + dockWindow.liftRoom
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: dockWindow.reveal ? parent.height - dockWindow.bottomMargin - height : dockWindow.height + 1

                    Behavior on y {
                        NumberAnimation {
                            duration: Looks.animation.normal
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Looks.animation.standard
                        }
                    }

                    MGlass {
                        id: capsule
                        backdrop: dockBackdrop
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: dockWindow.layout.width + dockWindow.padding * 2
                        height: dockWindow.capsuleHeight

                        Behavior on width {
                            NumberAnimation {
                                duration: Looks.animation.fast
                                easing.type: Easing.OutQuad
                            }
                        }
                    }

                    Item {
                        id: iconRow
                        anchors {
                            bottom: parent.bottom
                            bottomMargin: dockWindow.indicatorArea
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: dockWindow.layout.width
                        height: dockWindow.maxSize

                        Repeater {
                            model: dockWindow.apps

                            MacosDockItem {
                                required property int index
                                required property var modelData

                                entry: modelData
                                slot: dockWindow.layout.items[index] ?? ({
                                        x: 0,
                                        size: dockWindow.base,
                                        separator: false
                                    })
                                indicatorArea: dockWindow.indicatorArea
                                capsuleHeight: dockWindow.capsuleHeight
                                dock: dockWindow
                                itemIndex: index
                            }
                        }
                    }
                }
            }
        }
    }
}
