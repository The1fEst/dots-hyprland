pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.macos.items
import qs.modules.macos.looks
import qs.modules.macos.controlCenter
import qs.modules.macos.notificationCenter

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        Scope {
            id: screenScope
            required property var modelData

            property bool notificationCenterOpen: false
            property bool controlCenterOpen: false
            property bool editMode: false
            property string expanded: ""

            onControlCenterOpenChanged: {
                if (!controlCenterOpen) {
                    editMode = false;
                    expanded = "";
                }
            }

            onEditModeChanged: {
                if (editMode)
                    expanded = "";
            }

            PanelWindow {
                id: barWindow

                screen: screenScope.modelData
                visible: !GlobalStates.screenLocked
                color: "transparent"
                exclusiveZone: Looks.sizes.menuBarHeight
                implicitHeight: Looks.sizes.menuBarHeight
                WlrLayershell.namespace: "quickshell:macosMenuBar"
                anchors {
                    top: true
                    left: true
                    right: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onPressed: {
                        screenScope.controlCenterOpen = false;
                        screenScope.notificationCenterOpen = false;
                    }
                }

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        top: parent.top
                        bottom: parent.bottom
                    }
                    spacing: Looks.sizes.menuBarItemSpacing

                    MMenuBarWorkspaces {}

                    MMenuBarItem {
                        MText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                const appId = ToplevelManager.activeToplevel?.appId ?? "";
                                if (appId.length === 0)
                                    return "Finder";
                                const entry = DesktopEntries.heuristicLookup(appId);
                                if (entry?.name)
                                    return entry.name;
                                const leaf = appId.split(".").pop();
                                return leaf.charAt(0).toUpperCase() + leaf.slice(1);
                            }
                            emphasized: true
                            color: Looks.colors.primary
                        }
                    }
                }

                Row {
                    anchors {
                        right: parent.right
                        rightMargin: 10
                        top: parent.top
                        bottom: parent.bottom
                    }
                    spacing: Looks.sizes.menuBarItemSpacing

                    MMenuBarItems {
                        editMode: screenScope.editMode
                        dragOriginX: screenScope.modelData.x
                        dragOriginY: screenScope.modelData.y
                        screenName: screenScope.modelData.name
                        activeItem: screenScope.controlCenterOpen ? screenScope.expanded : ""
                        onExpandRequested: id => {
                            if (screenScope.controlCenterOpen && screenScope.expanded === id) {
                                screenScope.controlCenterOpen = false;
                                return;
                            }
                            screenScope.notificationCenterOpen = false;
                            screenScope.controlCenterOpen = true;
                            screenScope.expanded = id;
                        }
                    }

                    MMenuBarItem {
                        active: screenScope.controlCenterOpen
                        onClicked: {
                            screenScope.notificationCenterOpen = false;
                            screenScope.controlCenterOpen = !screenScope.controlCenterOpen;
                        }
                        MaterialSymbol {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "tune"
                            iconSize: 18
                            color: Looks.colors.primary
                        }
                    }

                    MMenuBarItem {
                        active: screenScope.notificationCenterOpen
                        onClicked: {
                            screenScope.controlCenterOpen = false;
                            screenScope.notificationCenterOpen = !screenScope.notificationCenterOpen;
                        }
                        MText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: `${DateTime.longDate}  ${DateTime.time}`
                            color: Looks.colors.primary
                        }
                    }
                }

            }

            MacosControlCenter {
                screenData: screenScope.modelData
                open: screenScope.controlCenterOpen
                editMode: screenScope.editMode
                expanded: screenScope.expanded
                onEditRequested: screenScope.editMode = !screenScope.editMode
                onExpandRequested: id => screenScope.expanded = id
                onCollapseRequested: screenScope.expanded = ""
            }

            MacosNotificationCenter {
                screenData: screenScope.modelData
                open: screenScope.notificationCenterOpen
            }

        }
    }
}
