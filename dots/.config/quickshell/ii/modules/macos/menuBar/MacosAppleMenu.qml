pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.macos.looks

PanelWindow {
    id: root

    required property var screenData
    property bool open: false

    signal dismissed

    readonly property real sideMargin: 6
    readonly property real menuWidth: 240

    readonly property list<var> entries: [
        {
            label: "System Settings…",
            run: () => Quickshell.execDetached(["qs", "-p", Quickshell.shellPath("settings.qml")])
        },
        {
            separator: true
        },
        {
            label: "Sleep",
            run: () => Session.suspend()
        },
        {
            label: "Restart…",
            run: () => Session.reboot()
        },
        {
            label: "Shut Down…",
            run: () => Session.poweroff()
        },
        {
            separator: true
        },
        {
            label: "Lock Screen",
            run: () => Session.lock()
        },
        {
            label: "Log Out…",
            run: () => Session.logout()
        }
    ]

    function activate(entry: var): void {
        root.dismissed();
        entry.run();
    }

    screen: root.screenData
    visible: root.open
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: root.menuWidth + root.sideMargin * 2 + Looks.sizes.shadowMargin
    WlrLayershell.namespace: "quickshell:macosAppleMenu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors {
        top: true
        left: true
        bottom: true
    }

    mask: Region {
        item: root.open ? menu : null
    }

    MGlassBackdrop {
        id: backdrop
        screenY: Looks.sizes.menuBarHeight
        panelWidth: root.width
        panelHeight: root.height
        captureWindows: root.open
    }

    MGlass {
        id: menu
        backdrop: backdrop
        anchors {
            left: parent.left
            leftMargin: root.sideMargin
            top: parent.top
        }
        width: root.menuWidth
        height: rows.implicitHeight + 12
        radius: Looks.radius.huge

        Column {
            id: rows
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            Repeater {
                model: root.entries

                MenuRow {
                    required property var modelData

                    width: rows.width
                    entry: modelData
                }
            }
        }
    }

    component MenuRow: Item {
        id: row

        required property var entry
        readonly property bool separator: row.entry.separator ?? false

        implicitHeight: row.separator ? 11 : 26

        Rectangle {
            anchors {
                fill: parent
                leftMargin: 8
                rightMargin: 8
            }
            visible: !row.separator && hoverArea.containsMouse
            radius: Looks.radius.small
            color: Looks.accent
            antialiasing: true
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: 14
                rightMargin: 14
                verticalCenter: parent.verticalCenter
            }
            visible: row.separator
            height: 1
            color: Looks.colors.divider
        }

        MText {
            anchors {
                left: parent.left
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }
            visible: !row.separator
            text: row.entry.label ?? ""
            color: hoverArea.containsMouse ? "#ffffff" : Looks.colors.primary
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            enabled: !row.separator
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activate(row.entry)
        }
    }
}
