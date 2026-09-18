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
}
