import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    ContentSection {
        icon: "lock"
        title: Translation.tr("Privacy")

        ContentLinkRow {
            buttonIcon: "lock"
            title: Translation.tr("Screen Lock")
            subtitle: Translation.tr("What the lock screen looks like and what it lets through")
            onClicked: root.subpageRequested(title, "modules/settings/LockConfig.qml")
        }

        ContentLinkRow {
            buttonIcon: "screenshot_frame_2"
            title: Translation.tr("Screenshots & Recording")
            subtitle: Translation.tr("Where captures go and how the region selector behaves")
            onClicked: root.subpageRequested(title, "modules/settings/CaptureConfig.qml")
        }
    }

    ContentSection {
        icon: "sensors"
        title: Translation.tr("In use right now")

        ConfigRow {
            uniform: true

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 52
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer2

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                    }
                    spacing: 10

                    MaterialSymbol {
                        text: "mic"
                        iconSize: Appearance.font.pixelSize.larger
                        color: Privacy.micActive.length > 0 ? Appearance.colors.colError : Appearance.colors.colSubtext
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: Privacy.micActive.length > 0 ? Translation.tr("Microphone in use") : Translation.tr("Microphone idle")
                        color: Appearance.colors.colOnLayer2
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 52
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer2

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                    }
                    spacing: 10

                    MaterialSymbol {
                        text: "screen_share"
                        iconSize: Appearance.font.pixelSize.larger
                        color: Privacy.screenSharing.length > 0 ? Appearance.colors.colError : Appearance.colors.colSubtext
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: Privacy.screenSharing.length > 0 ? Translation.tr("Screen being shared") : Translation.tr("Screen not shared")
                        color: Appearance.colors.colOnLayer2
                    }
                }
            }
        }
    }

    ContentSection {
        icon: "work_alert"
        title: Translation.tr("Work safety")

        ConfigSwitch {
            buttonIcon: "assignment"
            text: Translation.tr("Hide clipboard images copied from sussy sources")
            checked: Config.options.workSafety.enable.clipboard
            onCheckedChanged: {
                Config.options.workSafety.enable.clipboard = checked;
            }
        }
        ConfigSwitch {
            buttonIcon: "wallpaper"
            text: Translation.tr("Hide sussy/anime wallpapers")
            checked: Config.options.workSafety.enable.wallpaper
            onCheckedChanged: {
                Config.options.workSafety.enable.wallpaper = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Trigger keywords")
            tooltip: Translation.tr("Comma-separated. Work safety kicks in when one of these shows up.")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Network names")
                text: (Config.options.workSafety.triggerCondition.networkNameKeywords ?? []).join(", ")
                onEditingFinished: {
                    Config.options.workSafety.triggerCondition.networkNameKeywords = StringUtils.splitList(text);
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("File names")
                text: (Config.options.workSafety.triggerCondition.fileKeywords ?? []).join(", ")
                onEditingFinished: {
                    Config.options.workSafety.triggerCondition.fileKeywords = StringUtils.splitList(text);
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Links")
                text: (Config.options.workSafety.triggerCondition.linkKeywords ?? []).join(", ")
                onEditingFinished: {
                    Config.options.workSafety.triggerCondition.linkKeywords = StringUtils.splitList(text);
                }
            }
        }
    }
}
