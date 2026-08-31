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

    readonly property real sideMargin: 12

    // Whatever the header and the calendar leave over: notifications scroll rather than
    // running off the bottom of the screen.
    readonly property real maxListHeight: Math.max(0, root.height - headerRow.height - calendarCard.height - root.sideMargin * 2 - contentColumn.spacing * 2)

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
        item: root.open ? contentColumn : null
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
                id: contentColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: root.sideMargin
                }
                spacing: 10

                RowLayout {
                    id: headerRow
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

                    MHeaderButton {
                        backdrop: backdrop
                        iconName: "close"
                        label: "Clear All"
                        showLabel: hovered
                        onClicked: Notifications.discardAllNotifications()
                    }
                }

                Flickable {
                    id: notificationScroll

                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(notificationList.implicitHeight, root.maxListHeight)
                    contentWidth: width
                    contentHeight: notificationList.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: contentHeight > height

                    Column {
                        id: notificationList
                        width: notificationScroll.width
                        spacing: 10

                        Repeater {
                            model: Notifications.appNameList

                            MNotificationGroup {
                                required property string modelData

                                width: notificationList.width
                                backdrop: backdrop
                                panelOpen: root.open
                                group: Notifications.groupsByAppName[modelData]
                            }
                        }
                    }

                    Rectangle {
                        anchors {
                            right: parent.right
                            rightMargin: 2
                        }
                        visible: notificationScroll.interactive
                        width: 4
                        radius: width / 2
                        color: Looks.colors.tertiary
                        opacity: notificationScroll.moving ? 1 : 0
                        y: notificationScroll.contentY + notificationScroll.height * (notificationScroll.contentY / notificationScroll.contentHeight)
                        height: notificationScroll.height * (notificationScroll.height / notificationScroll.contentHeight)

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                MGlass {
                    id: calendarCard
                    Layout.fillWidth: true
                    Layout.preferredHeight: calendarWidget.implicitHeight + 32
                    backdrop: backdrop

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
            }
        }
    }
}
