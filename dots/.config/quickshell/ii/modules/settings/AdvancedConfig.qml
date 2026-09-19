import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "swipe"
        title: Translation.tr("Scrolling")

        ConfigSwitch {
            buttonIcon: "touch_app"
            text: Translation.tr("Faster touchpad scrolling")
            checked: Config.options.interactions.scrolling.fasterTouchpadScroll
            onCheckedChanged: {
                Config.options.interactions.scrolling.fasterTouchpadScroll = checked;
            }
        }

        ConfigSpinBox {
            icon: "mouse"
            text: Translation.tr("Mouse scroll distance")
            value: Config.options.interactions.scrolling.mouseScrollFactor
            from: 10
            to: 1000
            stepSize: 10
            onValueChanged: {
                Config.options.interactions.scrolling.mouseScrollFactor = value;
            }
        }

        ConfigSpinBox {
            icon: "touchpad_mouse"
            text: Translation.tr("Touchpad scroll distance")
            value: Config.options.interactions.scrolling.touchpadScrollFactor
            from: 10
            to: 1000
            stepSize: 10
            onValueChanged: {
                Config.options.interactions.scrolling.touchpadScrollFactor = value;
            }
        }

        ConfigSpinBox {
            icon: "conversion_path"
            text: Translation.tr("Mouse detection threshold")
            value: Config.options.interactions.scrolling.mouseScrollDeltaThreshold
            from: 1
            to: 500
            stepSize: 10
            onValueChanged: {
                Config.options.interactions.scrolling.mouseScrollDeltaThreshold = value;
            }
            StyledToolTip {
                text: Translation.tr("Scroll events at least this large are treated as coming from a mouse instead of a touchpad")
            }
        }
    }

    ContentSection {
        icon: "bug_report"
        title: Translation.tr("Workarounds")

        ConfigSwitch {
            buttonIcon: "border_outer"
            text: Translation.tr("Dead pixel workaround")
            checked: Config.options.interactions.deadPixelWorkaround.enable
            onCheckedChanged: {
                Config.options.interactions.deadPixelWorkaround.enable = checked;
            }
            StyledToolTip {
                text: Translation.tr("Hyprland leaves out one pixel on the right and bottom edges for interactions. Enable if screen corners don't react to your cursor.")
            }
        }

        ConfigSpinBox {
            icon: "hourglass"
            text: Translation.tr("Race condition delay (ms)")
            value: Config.options.hacks.arbitraryRaceConditionDelay
            from: 0
            to: 500
            stepSize: 5
            onValueChanged: {
                Config.options.hacks.arbitraryRaceConditionDelay = value;
            }
            StyledToolTip {
                text: Translation.tr("Increase if things occasionally show up in the wrong place or size on a slow system")
            }
        }
    }
}
