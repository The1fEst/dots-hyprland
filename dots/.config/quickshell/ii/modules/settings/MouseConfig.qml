import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    readonly property var scrollMethods: [
        {
            displayName: Translation.tr("Two fingers or wheel"),
            value: "2fg"
        },
        {
            displayName: Translation.tr("Along the edge"),
            value: "edge"
        },
        {
            displayName: Translation.tr("While a button is held"),
            value: "on_button_down"
        },
        {
            displayName: Translation.tr("No scrolling"),
            value: "no_scroll"
        }
    ]

    function indexOfValue(options: var, value: var): int {
        const found = options.findIndex(option => option.value === value);
        return found !== -1 ? found : 0;
    }

    ContentSection {
        icon: "mouse"
        title: Translation.tr("General")

        ContentSubsection {
            title: Translation.tr("Primary button")
            tooltip: Translation.tr("Order of the physical buttons on mice and touchpads")

            ConfigSelectionArray {
                currentValue: HyprlandOptions.flag("input:left_handed")
                onSelected: newValue => HyprlandOptions.set("input:left_handed", newValue)
                options: [
                    {
                        displayName: Translation.tr("Left"),
                        icon: "arrow_back",
                        value: false
                    },
                    {
                        displayName: Translation.tr("Right"),
                        icon: "arrow_forward",
                        value: true
                    }
                ]
            }
        }
    }

    ContentSection {
        icon: "mouse"
        title: Translation.tr("Mouse")

        ContentSubsection {
            title: Translation.tr("Pointer speed")

            ConfigSlider {
                buttonIcon: "speed"
                text: Translation.tr("Speed")
                usePercentTooltip: false
                from: -100
                to: 100
                value: Math.round(HyprlandOptions.number("input:sensitivity") * 100)
                onMoved: speed => HyprlandOptions.set("input:sensitivity", speed / 100)
            }
        }

        OptionSwitch {
            buttonIcon: "trending_up"
            text: Translation.tr("Mouse acceleration")
            current: HyprlandOptions.text("input:accel_profile") !== "flat"
            onCommitted: accelerated => HyprlandOptions.set("input:accel_profile", accelerated ? "adaptive" : "flat")

            StyledToolTip {
                text: Translation.tr("Off moves the pointer exactly as far as the mouse moved, which games and drawing want.\nOn speeds the pointer up as the mouse moves faster.")
            }
        }

        ContentSubsection {
            title: Translation.tr("Scrolling")

            HyprlandSwitch {
                buttonIcon: "swap_vert"
                text: Translation.tr("Natural scrolling")
                option: "input:natural_scroll"

                StyledToolTip {
                    text: Translation.tr("Scrolling moves the content rather than the view.")
                }
            }

            StyledComboBox {
                buttonIcon: "mouse"
                textRole: "displayName"
                model: root.scrollMethods
                currentIndex: root.indexOfValue(root.scrollMethods, HyprlandOptions.text("input:scroll_method"))
                onActivated: index => HyprlandOptions.set("input:scroll_method", root.scrollMethods[index].value)
            }

            OptionSpinBox {
                icon: "height"
                text: Translation.tr("Scroll amount (%)")
                current: Math.round(HyprlandOptions.number("input:scroll_factor") * 100)
                from: 10
                to: 500
                stepSize: 10
                onCommitted: factor => HyprlandOptions.set("input:scroll_factor", factor / 100)
            }
        }
    }

    ContentSection {
        icon: "highlight_mouse_cursor"
        title: Translation.tr("Pointer")

        ContentSubsection {
            title: Translation.tr("Hiding")

            OptionSpinBox {
                icon: "timer"
                text: Translation.tr("Hide when still for (s)")
                current: HyprlandOptions.number("cursor:inactive_timeout")
                from: 0
                to: 120
                stepSize: 1
                onCommitted: seconds => HyprlandOptions.set("cursor:inactive_timeout", seconds)

                StyledToolTip {
                    text: Translation.tr("Zero keeps the pointer on screen no matter how long it sits still.")
                }
            }

            HyprlandSwitch {
                buttonIcon: "keyboard_hide"
                text: Translation.tr("Hide while typing")
                option: "cursor:hide_on_key_press"
            }
        }

        ContentSubsection {
            title: Translation.tr("Drawing")

            OptionSwitch {
                buttonIcon: "memory"
                text: Translation.tr("Let the screen draw the pointer")
                current: HyprlandOptions.number("cursor:no_hardware_cursors") === 0
                onCommitted: hardware => HyprlandOptions.set("cursor:no_hardware_cursors", hardware ? 0 : 1)

                StyledToolTip {
                    text: Translation.tr("A pointer the screen draws itself stays smooth whatever the rest of the screen is doing.\nTurn it off if the pointer disappears or is drawn in the wrong place.")
                }
            }

            HyprlandSwitch {
                buttonIcon: "animated_images"
                text: Translation.tr("Use hyprcursor themes")
                option: "cursor:enable_hyprcursor"
            }
        }
    }

    ContentSection {
        icon: "touch_app"
        title: Translation.tr("Touchpad")

        HyprlandSwitch {
            buttonIcon: "keyboard"
            text: Translation.tr("Disable while typing")
            option: "input:touchpad:disable_while_typing"
        }

        ContentSubsection {
            title: Translation.tr("Clicking")

            HyprlandSwitch {
                buttonIcon: "touch_app"
                text: Translation.tr("Tap to click")
                option: "input:touchpad:tap-to-click"

                StyledToolTip {
                    text: Translation.tr("Quickly touch the touchpad to click.")
                }
            }

            HyprlandSwitch {
                buttonIcon: "drag_pan"
                text: Translation.tr("Tap and drag")
                option: "input:touchpad:tap-and-drag"
            }

            HyprlandSwitch {
                buttonIcon: "pan_tool"
                text: Translation.tr("Middle click with three fingers")
                option: "input:touchpad:middle_button_emulation"
            }

            ContentSubsection {
                title: Translation.tr("Secondary click")

                ConfigSelectionArray {
                    currentValue: HyprlandOptions.flag("input:touchpad:clickfinger_behavior")
                    onSelected: newValue => HyprlandOptions.set("input:touchpad:clickfinger_behavior", newValue)
                    options: [
                        {
                            displayName: Translation.tr("Corner push"),
                            icon: "south_west",
                            value: false
                        },
                        {
                            displayName: Translation.tr("Two finger push"),
                            icon: "touch_app",
                            value: true
                        }
                    ]
                }
            }

            ContentSubsection {
                title: Translation.tr("Tap with two or three fingers")

                ConfigSelectionArray {
                    currentValue: HyprlandOptions.text("input:touchpad:tap_button_map") || "lrm"
                    onSelected: newValue => HyprlandOptions.set("input:touchpad:tap_button_map", newValue)
                    options: [
                        {
                            displayName: Translation.tr("Right, then middle"),
                            icon: "arrow_forward",
                            value: "lrm"
                        },
                        {
                            displayName: Translation.tr("Middle, then right"),
                            icon: "arrow_upward",
                            value: "lmr"
                        }
                    ]
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Scrolling")

            HyprlandSwitch {
                buttonIcon: "swap_vert"
                text: Translation.tr("Natural scrolling")
                option: "input:touchpad:natural_scroll"
            }

            OptionSpinBox {
                icon: "height"
                text: Translation.tr("Scroll amount (%)")
                current: Math.round(HyprlandOptions.number("input:touchpad:scroll_factor") * 100)
                from: 10
                to: 500
                stepSize: 10
                onCommitted: factor => HyprlandOptions.set("input:touchpad:scroll_factor", factor / 100)
            }
        }
    }
}
