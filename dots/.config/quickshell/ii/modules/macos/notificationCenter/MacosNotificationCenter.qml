pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.modules.common.widgets
import qs.modules.macos.looks

PanelWindow {
    id: root

    required property var screenData
    property bool open: false

    signal requestClose

    readonly property real sideMargin: 12

    screen: screenData
    visible: open
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 380
    WlrLayershell.namespace: "quickshell:macosNotificationCenter"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors {
        top: true
        right: true
        bottom: true
    }

    mask: Region {
        item: root.open ? contentRoot : null
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

        Item {
            anchors.fill: parent
            visible: root.open

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: root.sideMargin
                }
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 2

                    MText {
                        text: "Notification Center"
                        font.pixelSize: Looks.font.size.title
                        emphasized: true
                        color: Looks.colors.primary
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    MGlass {
                        backdrop: backdrop
                        implicitWidth: 22
                        implicitHeight: 22
                        radius: 11

                        MText {
                            anchors.centerIn: parent
                            text: "×"
                            font.pixelSize: Looks.font.size.normal
                            color: Looks.colors.secondary
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.requestClose()
                        }
                    }
                }

                Repeater {
                    model: Notifications.list

                    MNotificationCard {
                        required property var modelData

                        Layout.fillWidth: true
                        backdrop: backdrop
                        notif: modelData
                    }
                }

                MGlass {
                    Layout.fillWidth: true
                    Layout.preferredHeight: calendarWidget.implicitHeight + 32
                    backdrop: backdrop
                    radius: Looks.radius.media

                    ColumnLayout {
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                            margins: 16
                        }
                        width: 110
                        spacing: 0

                        MText {
                            text: Qt.locale().toString(new Date(), "dddd").toUpperCase()
                            font.pixelSize: Looks.font.size.small
                            emphasized: true
                            color: Looks.colors.red
                        }

                        MText {
                            text: new Date().getDate()
                            font.pixelSize: 34
                            display: true
                            color: Looks.colors.primary
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        MText {
                            text: "No Events Today"
                            font.pixelSize: Looks.font.size.small
                            color: Looks.colors.secondary
                        }
                    }

                    MCalendar {
                        id: calendarWidget
                        anchors {
                            right: parent.right
                            top: parent.top
                            margins: 16
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
