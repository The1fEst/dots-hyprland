pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.macos.looks

Item {
    id: root

    // The window is opaque, so these stand in for the materials the panels get from the
    // wallpaper behind them. The inactive sidebar tint is the right stand-in precisely
    // because that is the one macOS itself falls back to once translucency buys nothing.
    readonly property color sidebarColor: Looks.surfaces.sidebarInactive
    readonly property color paneColor: Looks.surfaces.panel

    Rectangle {
        id: sidebar
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: Looks.settings.sidebarWidth
        color: root.sidebarColor

        Column {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: Looks.settings.sidebarInset
                rightMargin: Looks.settings.sidebarInset
                topMargin: Looks.settings.sidebarTop
            }
            spacing: Looks.settings.sidebarUserGap

            Rectangle {
                width: parent.width
                height: Looks.settings.sidebarSearchHeight
                radius: height / 2
                color: Looks.surfaces.inputField
                antialiasing: true

                MSymbol {
                    id: searchIcon
                    anchors {
                        left: parent.left
                        leftMargin: Looks.settings.sidebarSearchGlyphInset
                        verticalCenter: parent.verticalCenter
                    }
                    symbol: "magnifyingglass"
                    symbolSize: 12.5
                    color: Looks.colors.secondary
                }

                TextInput {
                    id: search
                    anchors {
                        left: searchIcon.right
                        leftMargin: 5
                        right: parent.right
                        rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: Looks.font.text
                    font.pixelSize: 13
                    color: Looks.colors.primary
                    clip: true

                    MText {
                        anchors.fill: parent
                        visible: search.text.length === 0
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("Search")
                        font.pixelSize: 13
                        color: Looks.colors.secondary
                    }
                }
            }

            Item {
                width: parent.width
                height: Looks.settings.sidebarAvatarSize

                ClippingRectangle {
                    id: avatar
                    anchors {
                        left: parent.left
                        leftMargin: Looks.settings.sidebarRowInset - 3
                        verticalCenter: parent.verticalCenter
                    }
                    width: Looks.settings.sidebarAvatarSize
                    height: width
                    radius: width / 2
                    color: Looks.colors.quaternary
                    antialiasing: true

                    StyledImage {
                        id: avatarImage
                        anchors.fill: parent
                        source: Directories.userAvatarPathAccountsService
                        fallbacks: [Directories.userAvatarPathRicersAndWeirdSystems, Directories.userAvatarPathRicersAndWeirdSystems2]
                        sourceSize: Qt.size(76, 76)
                        fillMode: Image.PreserveAspectCrop
                    }

                    MSymbol {
                        anchors.centerIn: parent
                        visible: avatarImage.status !== Image.Ready
                        symbol: "person"
                        symbolSize: 19
                        color: Looks.colors.secondary
                    }
                }

                Column {
                    anchors {
                        left: avatar.right
                        leftMargin: Looks.settings.sidebarAvatarGap
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 1

                    MText {
                        width: parent.width
                        text: SystemInfo.username
                        elide: Text.ElideRight
                        emphasized: true
                        color: Looks.colors.primary
                    }

                    MText {
                        width: parent.width
                        text: SystemInfo.distroName
                        elide: Text.ElideRight
                        color: Looks.colors.secondary
                    }
                }
            }

            Column {
                width: parent.width
                topPadding: Looks.settings.sidebarListGap - Looks.settings.sidebarUserGap

                Repeater {
                    model: MSettingsNav.pages

                    Item {
                        id: listSlot

                        required property var modelData
                        required property int index

                        // A gap wherever the group changes, which is all macOS uses to
                        // divide the list.
                        readonly property bool startsGroup: index > 0 && modelData.group !== MSettingsNav.pages[index - 1].group

                        width: parent.width
                        visible: !(modelData.hidden ?? false) && (search.text.length === 0 || modelData.name.toLowerCase().includes(search.text.toLowerCase()))
                        height: visible ? Looks.settings.sidebarRowHeight + (startsGroup ? Looks.settings.sidebarSectionGap : 0) : 0

                        MSettingsSidebarItem {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }
                            label: listSlot.modelData.name
                            icon: listSlot.modelData.icon
                            tint: listSlot.modelData.tint
                            current: listSlot.index === MSettingsNav.currentIndex
                            onClicked: MSettingsNav.visit(listSlot.index)
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: pane
        anchors {
            left: sidebar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        color: root.paneColor

        Item {
            id: header
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: Looks.metrics.titlebar.height

            Rectangle {
                id: navGroup
                x: Looks.settings.toolbarInset
                anchors.verticalCenter: parent.verticalCenter
                width: Looks.control.toolbarGroupInset * 2 + Looks.control.toolbarButtonLarge * 2 + Looks.control.toolbarGroupGap
                height: Looks.control.toolbarGroupHeight
                radius: height / 2
                color: Looks.colors.quinary
                border.width: 1
                border.color: Looks.colors.quaternary
                antialiasing: true

                Rectangle {
                    anchors.centerIn: parent
                    width: 1
                    height: Looks.control.toolbarSeparatorHeight
                    color: Looks.colors.tertiary
                }

                Repeater {
                    model: [
                        {
                            icon: "chevron.left",
                            delta: -1
                        },
                        {
                            icon: "chevron.right",
                            delta: 1
                        }
                    ]

                    MSymbol {
                        required property var modelData
                        required property int index

                        readonly property bool available: MSettingsNav.canStep(modelData.delta)

                        x: Looks.control.toolbarGroupInset + index * (Looks.control.toolbarButtonLarge + Looks.control.toolbarGroupGap) + (Looks.control.toolbarButtonLarge - width) / 2
                        anchors.verticalCenter: parent.verticalCenter
                        symbol: modelData.icon
                        symbolSize: Looks.control.toolbarGlyphSizeLarge
                        color: available ? Looks.colors.primary : Looks.colors.tertiary

                        MouseArea {
                            anchors.fill: parent
                            enabled: parent.available
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MSettingsNav.step(parent.modelData.delta)
                        }
                    }
                }
            }

            MText {
                anchors {
                    left: navGroup.right
                    leftMargin: Looks.settings.toolbarTitleGap
                    verticalCenter: parent.verticalCenter
                }
                text: MSettingsNav.currentPage?.name ?? ""
                textStyle: Looks.font.style.title2
                emphasized: true
                color: Looks.colors.primary
            }
        }

        Flickable {
            anchors {
                left: parent.left
                right: parent.right
                top: header.bottom
                bottom: parent.bottom
                topMargin: Looks.settings.paneTopGap
            }
            contentHeight: body.implicitHeight + 40
            clip: true

            Column {
                id: body
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    leftMargin: Looks.settings.formInset
                    rightMargin: Looks.settings.formInset
                }
                spacing: Looks.settings.formGap

                Loader {
                    width: parent.width
                    source: MSettingsNav.currentPage ? Qt.resolvedUrl(MSettingsNav.currentPage.pane) : ""
                }
            }
        }
    }
}
