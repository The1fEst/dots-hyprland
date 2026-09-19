import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "folder"
        title: Translation.tr("Save paths")

        ContentSubsection {
            title: Translation.tr("Screenshots")
            tooltip: Translation.tr("Leave empty to only copy to the clipboard")

            OptionTextArea {
                Layout.fillWidth: true
                placeholderText: Translation.tr("e.g. ~/Pictures/Screenshots")
                current: Config.options.screenSnip.savePath
                wrapMode: TextEdit.Wrap
                onCommitted: value => Config.options.screenSnip.savePath = value
            }
        }

        ContentSubsection {
            title: Translation.tr("Screen recordings")

            OptionTextArea {
                Layout.fillWidth: true
                placeholderText: Translation.tr("e.g. ~/Videos/Recordings")
                current: Config.options.screenRecord.savePath
                wrapMode: TextEdit.Wrap
                onCommitted: value => Config.options.screenRecord.savePath = value
            }
        }
    }

    ContentSection {
        icon: "screenshot_frame_2"
        title: Translation.tr("Region selector (screen snipping)")

        ContentSubsection {
            title: Translation.tr("Hint target regions")
            ConfigRow {
                ConfigSwitch {
                    buttonIcon: "select_window"
                    text: Translation.tr('Windows')
                    checked: Config.options.regionSelector.targetRegions.windows
                    onCheckedChanged: {
                        Config.options.regionSelector.targetRegions.windows = checked;
                    }
                }
                ConfigSwitch {
                    buttonIcon: "right_panel_open"
                    text: Translation.tr('Layers')
                    checked: Config.options.regionSelector.targetRegions.layers
                    onCheckedChanged: {
                        Config.options.regionSelector.targetRegions.layers = checked;
                    }
                }
            }

            ConfigSwitch {
                buttonIcon: "label"
                text: Translation.tr('Show region labels')
                checked: Config.options.regionSelector.targetRegions.showLabel
                onCheckedChanged: {
                    Config.options.regionSelector.targetRegions.showLabel = checked;
                }
            }

            ConfigSpinBox {
                icon: "opacity"
                text: Translation.tr("Hint opacity (%)")
                value: Math.round(Config.options.regionSelector.targetRegions.opacity * 100)
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.regionSelector.targetRegions.opacity = value / 100;
                }
            }

            ConfigSpinBox {
                icon: "padding"
                text: Translation.tr("Selection padding")
                value: Config.options.regionSelector.targetRegions.selectionPadding
                from: 0
                to: 50
                stepSize: 1
                onValueChanged: {
                    Config.options.regionSelector.targetRegions.selectionPadding = value;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Rectangular selection")

            ConfigSwitch {
                buttonIcon: "point_scan"
                text: Translation.tr("Show aim lines")
                checked: Config.options.regionSelector.rect.showAimLines
                onCheckedChanged: {
                    Config.options.regionSelector.rect.showAimLines = checked;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Circle selection")

            ConfigSpinBox {
                icon: "eraser_size_3"
                text: Translation.tr("Stroke width")
                value: Config.options.regionSelector.circle.strokeWidth
                from: 1
                to: 20
                stepSize: 1
                onValueChanged: {
                    Config.options.regionSelector.circle.strokeWidth = value;
                }
            }

            ConfigSpinBox {
                icon: "screenshot_frame_2"
                text: Translation.tr("Padding")
                value: Config.options.regionSelector.circle.padding
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.regionSelector.circle.padding = value;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Annotation")

            ConfigSwitch {
                buttonIcon: "draw"
                text: Translation.tr("Use Satty")
                checked: Config.options.regionSelector.annotation.useSatty
                onCheckedChanged: {
                    Config.options.regionSelector.annotation.useSatty = checked;
                }
                StyledToolTip {
                    text: Translation.tr("Opens screenshots in Satty instead of the built-in annotation tool. Requires satty to be installed.")
                }
            }
        }
    }
}
