pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
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

                    MMenuBarTray {}

                    MMenuBarItem {
                        visible: Battery.available
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
            }

            MacosNotificationCenter {
                screenData: screenScope.modelData
                open: screenScope.notificationCenterOpen
                onRequestClose: screenScope.notificationCenterOpen = false
            }

        }
    }
}
