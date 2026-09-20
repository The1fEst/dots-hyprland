import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    component DeviceFact: ConfigRow {
        required property string label
        required property string value
        visible: value.length > 0
        uniform: false
        StyledText {
            Layout.leftMargin: 8
            Layout.preferredWidth: 140
            text: label
            color: Appearance.colors.colSubtext
        }
        StyledText {
            Layout.fillWidth: true
            Layout.rightMargin: 8
            text: value
            elide: Text.ElideRight
            color: Appearance.colors.colOnLayer0
        }
    }

    ContentSection {
        icon: "memory"
        title: Translation.tr("Device")

        DeviceFact {
            label: Translation.tr("Name")
            value: SystemInfo.hostname
        }
        DeviceFact {
            label: Translation.tr("Processor")
            value: SystemInfo.processor
        }
        DeviceFact {
            label: Translation.tr("Graphics")
            value: SystemInfo.graphics
        }
        DeviceFact {
            label: Translation.tr("Memory")
            value: SystemInfo.memory
        }
        DeviceFact {
            label: Translation.tr("Kernel")
            value: SystemInfo.kernel
        }
        DeviceFact {
            label: Translation.tr("Session")
            value: SystemInfo.desktopEnvironment.length > 0 ? `${SystemInfo.desktopEnvironment} (${SystemInfo.windowingSystem})` : ""
        }
    }

    ContentSection {
        icon: "storage"
        title: Translation.tr("Storage")
        visible: SystemInfo.disks.length > 0

        GridLayout {
            Layout.fillWidth: true
            columns: Math.max(1, Math.floor(root.baseWidth / 290))
            rowSpacing: 8
            columnSpacing: 8

            Repeater {
                model: SystemInfo.disks

                delegate: Rectangle {
                    id: disk
                    required property var modelData
                    readonly property real fraction: modelData.used / modelData.size

                    Layout.fillWidth: true
                    implicitHeight: diskColumn.implicitHeight + 24
                    radius: Appearance.rounding.normal
                    color: Appearance.colors.colLayer2

                    ColumnLayout {
                        id: diskColumn
                        anchors {
                            fill: parent
                            margins: 12
                        }
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            MaterialSymbol {
                                text: "hard_drive"
                                iconSize: Appearance.font.pixelSize.hugeass
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: disk.modelData.mount
                                elide: Text.ElideMiddle
                                color: Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                text: `${Math.round(disk.fraction * 100)}%`
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }
                        }

                        StyledProgressBar {
                            Layout.fillWidth: true
                            Layout.topMargin: 2
                            Layout.bottomMargin: 2
                            value: disk.fraction
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: Translation.tr("%1 free of %2").arg(SystemInfo.humanSize(disk.modelData.size - disk.modelData.used)).arg(SystemInfo.humanSize(disk.modelData.size))
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: `${disk.modelData.source} · ${disk.modelData.fstype}`
                            elide: Text.ElideRight
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            color: Appearance.colors.colSubtext
                        }
                    }
                }
            }
        }
    }

    ContentSection {
        icon: "box"
        title: Translation.tr("Distro")
        
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            IconImage {
                implicitSize: 80
                source: Quickshell.iconPath(SystemInfo.logo)
            }
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                // spacing: 10
                StyledText {
                    text: SystemInfo.distroName
                    font.pixelSize: Appearance.font.pixelSize.title
                }
                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: SystemInfo.homeUrl
                    textFormat: Text.MarkdownText
                    onLinkActivated: (link) => {
                        Qt.openUrlExternally(link)
                    }
                    PointingHandLinkHover {}
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 5

            RippleButtonWithIcon {
                materialIcon: "auto_stories"
                mainText: Translation.tr("Documentation")
                onClicked: {
                    Qt.openUrlExternally(SystemInfo.documentationUrl)
                }
            }
            RippleButtonWithIcon {
                materialIcon: "support"
                mainText: Translation.tr("Help & Support")
                onClicked: {
                    Qt.openUrlExternally(SystemInfo.supportUrl)
                }
            }
            RippleButtonWithIcon {
                materialIcon: "bug_report"
                mainText: Translation.tr("Report a Bug")
                onClicked: {
                    Qt.openUrlExternally(SystemInfo.bugReportUrl)
                }
            }
            RippleButtonWithIcon {
                materialIcon: "policy"
                materialIconFill: false
                mainText: Translation.tr("Privacy Policy")
                onClicked: {
                    Qt.openUrlExternally(SystemInfo.privacyPolicyUrl)
                }
            }
            
        }

    }
    ContentSection {
        icon: "folder_managed"
        title: Translation.tr("Dotfiles")

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            Layout.topMargin: 10
            Layout.bottomMargin: 10
            IconImage {
                implicitSize: 80
                source: Quickshell.iconPath("illogical-impulse")
            }
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                // spacing: 10
                StyledText {
                    text: Translation.tr("illogical-impulse")
                    font.pixelSize: Appearance.font.pixelSize.title
                }
                StyledText {
                    text: "https://github.com/The1fEst/dots-hyprland"
                    font.pixelSize: Appearance.font.pixelSize.normal
                    textFormat: Text.MarkdownText
                    onLinkActivated: (link) => {
                        Qt.openUrlExternally(link)
                    }
                    PointingHandLinkHover {}
                }
                StyledText {
                    text: Translation.tr("Forked from %1").arg("https://github.com/end-4/dots-hyprland")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                    textFormat: Text.MarkdownText
                    onLinkActivated: (link) => {
                        Qt.openUrlExternally(link)
                    }
                    PointingHandLinkHover {}
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 5

            RippleButtonWithIcon {
                materialIcon: "auto_stories"
                mainText: Translation.tr("Documentation")
                onClicked: {
                    Qt.openUrlExternally("https://end-4.github.io/dots-hyprland-wiki/en/ii-qs/02usage/")
                }
            }
            RippleButtonWithIcon {
                materialIcon: "adjust"
                materialIconFill: false
                mainText: Translation.tr("Issues")
                onClicked: {
                    Qt.openUrlExternally("https://github.com/end-4/dots-hyprland/issues")
                }
            }
            RippleButtonWithIcon {
                materialIcon: "forum"
                mainText: Translation.tr("Discussions")
                onClicked: {
                    Qt.openUrlExternally("https://github.com/end-4/dots-hyprland/discussions")
                }
            }
            RippleButtonWithIcon {
                materialIcon: "favorite"
                mainText: Translation.tr("Donate")
                onClicked: {
                    Qt.openUrlExternally("https://github.com/sponsors/end-4")
                }
            }

            
        }
    }
}
