import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    ContentSection {
        icon: "visibility"
        title: Translation.tr("Seeing")

        OptionSpinBox {
            icon: "height"
            text: Translation.tr("Cursor size")
            current: DesktopAppearance.cursorSize
            from: 8
            to: 128
            stepSize: 4
            onCommitted: size => DesktopAppearance.setCursor(DesktopAppearance.cursorTheme, size)
        }

        OptionSwitch {
            buttonIcon: "animation"
            text: Translation.tr("Reduced motion")
            current: !HyprlandOptions.flag("animations:enabled")
            onCommitted: reduced => HyprlandOptions.set("animations:enabled", !reduced)

            StyledToolTip {
                text: Translation.tr("Windows and workspaces appear at once instead of moving.")
            }
        }

        HyprlandSwitch {
            buttonIcon: "open_with"
            text: Translation.tr("Animate manual resizes")
            option: "misc:animate_manual_resizes"
        }

        HyprlandSwitch {
            buttonIcon: "drag_pan"
            text: Translation.tr("Animate windows being dragged")
            option: "misc:animate_mouse_windowdragging"
        }
    }

    ContentSection {
        icon: "keyboard"
        title: Translation.tr("Typing")

        ContentSubsection {
            title: Translation.tr("Repeat keys")
            tooltip: Translation.tr("Key presses repeat when the key is held down")

            ConfigRow {
                uniform: true

                OptionSpinBox {
                    icon: "timer"
                    text: Translation.tr("Delay (ms)")
                    current: HyprlandOptions.number("input:repeat_delay")
                    from: 100
                    to: 2000
                    stepSize: 25
                    onCommitted: delay => HyprlandOptions.set("input:repeat_delay", delay)
                }

                OptionSpinBox {
                    icon: "speed"
                    text: Translation.tr("Rate (per second)")
                    current: HyprlandOptions.number("input:repeat_rate")
                    from: 1
                    to: 100
                    stepSize: 1
                    onCommitted: rate => HyprlandOptions.set("input:repeat_rate", rate)
                }
            }
        }
    }

    ContentSection {
        icon: "zoom_in"
        title: Translation.tr("Zoom")

        ContentSubsection {
            title: Translation.tr("Magnifier")
            tooltip: Translation.tr("The whole screen, magnified around the pointer. 100% is no magnification.")

            OptionSpinBox {
                icon: "zoom_in"
                text: Translation.tr("Magnification (%)")
                current: Math.round(HyprlandOptions.number("cursor:zoom_factor") * 100)
                from: 100
                to: 500
                stepSize: 10
                onCommitted: zoom => HyprlandOptions.set("cursor:zoom_factor", zoom / 100)
            }

            HyprlandSwitch {
                buttonIcon: "grid_on"
                text: Translation.tr("Keep the magnified image sharp")
                option: "cursor:zoom_rigid"
            }
        }
    }
}
