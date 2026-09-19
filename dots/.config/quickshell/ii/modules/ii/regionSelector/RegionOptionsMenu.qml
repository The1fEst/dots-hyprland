pragma ComponentBehavior: Bound
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

/**
 * What the next capture does, without leaving the selector.
 */
Item {
    id: root

    implicitWidth: 340
    implicitHeight: background.implicitHeight

    StyledRectangularShadow {
        target: background
    }

    Rectangle {
        id: background
        anchors.fill: parent
        implicitHeight: menuLayout.implicitHeight + 16
        radius: Appearance.rounding.normal
        color: Appearance.m3colors.m3surfaceContainer

        ColumnLayout {
            id: menuLayout
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 8
            }
            spacing: 2

            ContentSubsectionLabel {
                text: Translation.tr("Wait before capturing")
            }

            ConfigSelectionArray {
                currentValue: Config.options.regionSelector.countdownSeconds
                onSelected: newValue => Config.options.regionSelector.countdownSeconds = newValue
                options: [
                    {
                        displayName: Translation.tr("None"),
                        value: 0
                    },
                    {
                        displayName: Translation.tr("5s"),
                        value: 5
                    },
                    {
                        displayName: Translation.tr("10s"),
                        value: 10
                    }
                ]
            }

            ConfigSwitch {
                buttonIcon: "save"
                text: Translation.tr("Also save to a file")
                checked: Config.options.screenSnip.save
                onCheckedChanged: {
                    Config.options.screenSnip.save = checked;
                }
                StyledToolTip {
                    text: Config.options.screenSnip.savePath.length > 0 ? Config.options.screenSnip.savePath : Translation.tr("No folder is set yet — pick one in Settings")
                }
            }

            ConfigSwitch {
                buttonIcon: "mic"
                text: Translation.tr("Record the microphone")
                checked: Config.options.regionSelector.recordSound
                onCheckedChanged: {
                    Config.options.regionSelector.recordSound = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "arrow_selector_tool"
                text: Translation.tr("Include the pointer")
                checked: Config.options.regionSelector.showPointer
                onCheckedChanged: {
                    Config.options.regionSelector.showPointer = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "history"
                text: Translation.tr("Start from the last region")
                checked: Config.options.regionSelector.rememberRegion
                onCheckedChanged: {
                    Config.options.regionSelector.rememberRegion = checked;
                }
            }
        }
    }
}
