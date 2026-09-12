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
                    height: 12.5
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

            Rectangle {
                id: accountRow

                readonly property int page: MSettingsNav.pages.findIndex(entry => entry.pane === "MUserPane.qml")

                width: parent.width
                height: Looks.settings.sidebarAccountRowHeight
                radius: Looks.settings.sidebarSelectionRadius
                antialiasing: true
                color: MSettingsNav.currentIndex === accountRow.page ? Looks.accent : "transparent"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MSettingsNav.visit(accountRow.page)
                }

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
                        source: UserAccount.iconFile.length > 0 ? `file://${UserAccount.iconFile}` : ""
                        sourceSize: Qt.size(76, 76)
                        fillMode: Image.PreserveAspectCrop
                    }

                    MSymbol {
                        anchors.centerIn: parent
                        visible: avatarImage.status !== Image.Ready
                        symbol: "person.fill"
                        height: Looks.control.glyph.avatar
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
                        text: UserAccount.displayName
                        elide: Text.ElideRight
                        emphasized: true
                        color: MSettingsNav.currentIndex === accountRow.page ? "#ffffff" : Looks.colors.primary
                    }

                    MText {
                        width: parent.width
                        text: SystemInfo.distroName
                        elide: Text.ElideRight
                        color: MSettingsNav.currentIndex === accountRow.page ? "#ffffff" : Looks.colors.secondary
                        opacity: MSettingsNav.currentIndex === accountRow.page ? 0.8 : 1
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

        Canvas {
            id: band

            readonly property real notchCentre: page.item?.notchCentre ?? 0

            anchors {
                left: parent.left
                right: parent.right
            }
            y: -Math.max(0, content.contentY)
            height: page.item?.bandHeight ?? 0
            visible: band.height > 0

            onNotchCentreChanged: band.requestPaint()

            onPaint: {
                const context = getContext("2d");
                context.reset();

                const tail = page.item?.notchTail ?? 0;
                const centre = band.notchCentre;
                const edge = height - 0.5;

                context.beginPath();
                context.moveTo(0, 0);
                context.lineTo(width, 0);
                context.lineTo(width, edge);
                context.lineTo(centre + tail, edge);
                context.lineTo(centre, edge - tail);
                context.lineTo(centre - tail, edge);
                context.lineTo(0, edge);
                context.closePath();

                context.fillStyle = Looks.surfaces.header;
                context.fill();

                context.strokeStyle = Looks.surfaces.headerRule;
                context.lineWidth = 1;
                context.beginPath();
                context.moveTo(0, edge);
                context.lineTo(centre - tail, edge);
                context.lineTo(centre, edge - tail);
                context.lineTo(centre + tail, edge);
                context.lineTo(width, edge);
                context.stroke();
            }
        }

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

                property int hoveredStep: -1

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
                    visible: navGroup.hoveredStep < 0
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

                    Rectangle {
                        id: navButton

                        required property var modelData
                        required property int index

                        readonly property bool available: MSettingsNav.canStep(navButton.modelData.delta)

                        onAvailableChanged: {
                            if (!navButton.available && navGroup.hoveredStep === navButton.index)
                                navGroup.hoveredStep = -1;
                        }

                        x: Looks.control.toolbarGroupInset + navButton.index * (Looks.control.toolbarButtonLarge + Looks.control.toolbarGroupGap)
                        anchors.verticalCenter: parent.verticalCenter
                        width: Looks.control.toolbarButtonLarge
                        height: Looks.control.toolbarButtonLarge
                        radius: height / 2
                        antialiasing: true
                        color: navGroup.hoveredStep !== navButton.index ? "transparent" : step.pressed ? Looks.surfaces.buttonBorderedPressed : Looks.colors.hover

                        MSymbol {
                            anchors.centerIn: parent
                            symbol: navButton.modelData.icon
                            height: Looks.control.toolbarGlyphSizeLarge
                            color: navButton.available ? Looks.colors.primary : Looks.colors.tertiary
                        }

                        MouseArea {
                            id: step
                            anchors.fill: parent
                            enabled: navButton.available
                            hoverEnabled: true
                            cursorShape: navButton.available ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onEntered: navGroup.hoveredStep = navButton.index
                            onExited: {
                                if (navGroup.hoveredStep === navButton.index)
                                    navGroup.hoveredStep = -1;
                            }
                            onClicked: MSettingsNav.step(navButton.modelData.delta)
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
            id: content
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
                    id: page
                    width: parent.width
                    source: MSettingsNav.currentPage ? Qt.resolvedUrl(MSettingsNav.currentPage.pane) : ""
                }
            }
        }
    }
}
