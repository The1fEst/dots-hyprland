import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    readonly property string layout: HyprlandOptions.text("general:layout") || "dwindle"

    readonly property var masterPlaces: [
        {
            displayName: Translation.tr("A new window becomes the master"),
            value: "master"
        },
        {
            displayName: Translation.tr("A new window joins the stack"),
            value: "slave"
        },
        {
            displayName: Translation.tr("A new window takes the place of the one it opened from"),
            value: "inherit"
        }
    ]

    readonly property var masterSides: [
        {
            displayName: Translation.tr("Left"),
            value: "left"
        },
        {
            displayName: Translation.tr("Right"),
            value: "right"
        },
        {
            displayName: Translation.tr("Top"),
            value: "top"
        },
        {
            displayName: Translation.tr("Bottom"),
            value: "bottom"
        },
        {
            displayName: Translation.tr("Centre"),
            value: "center"
        }
    ]

    function indexOfValue(options: var, value: var): int {
        const found = options.findIndex(option => option.value === value);
        return found !== -1 ? found : 0;
    }

    ContentSection {
        icon: "grid_view"
        title: Translation.tr("Tiling")

        ContentSubsection {
            title: Translation.tr("Layout")

            ConfigSelectionArray {
                currentValue: root.layout
                onSelected: newValue => HyprlandOptions.set("general:layout", newValue)
                options: [
                    {
                        displayName: Translation.tr("Dwindle"),
                        icon: "splitscreen_right",
                        value: "dwindle"
                    },
                    {
                        displayName: Translation.tr("Master"),
                        icon: "splitscreen_left",
                        value: "master"
                    }
                ]
            }
        }

        ContentSubsection {
            title: Translation.tr("Spacing")

            Repeater {
                model: [
                    {
                        option: "general:gaps_in",
                        icon: "width",
                        name: Translation.tr("Gap between windows"),
                        to: 100
                    },
                    {
                        option: "general:gaps_out",
                        icon: "fit_screen",
                        name: Translation.tr("Gap around the screen"),
                        to: 200
                    },
                    {
                        option: "general:border_size",
                        icon: "border_outer",
                        name: Translation.tr("Border width"),
                        to: 20
                    }
                ]

                OptionSpinBox {
                    id: spacingOption

                    required property var modelData

                    icon: spacingOption.modelData.icon
                    text: spacingOption.modelData.name
                    current: HyprlandOptions.number(spacingOption.modelData.option)
                    from: 0
                    to: spacingOption.modelData.to
                    stepSize: 1
                    onCommitted: value => HyprlandOptions.set(spacingOption.modelData.option, value)
                }
            }
        }

        ContentSubsection {
            visible: root.layout === "dwindle"
            title: Translation.tr("Dwindle")

            HyprlandSwitch {
                buttonIcon: "splitscreen"
                text: Translation.tr("Keep the split direction when a window closes")
                option: "dwindle:preserve_split"
            }

            HyprlandSwitch {
                buttonIcon: "aspect_ratio"
                text: Translation.tr("Split along the longer side")
                option: "dwindle:smart_split"
            }

            HyprlandSwitch {
                buttonIcon: "open_in_full"
                text: Translation.tr("Resize towards the edge being dragged")
                option: "dwindle:smart_resizing"
            }

            OptionSpinBox {
                icon: "vertical_split"
                text: Translation.tr("New window takes (%)")
                current: Math.round(HyprlandOptions.number("dwindle:default_split_ratio") * 100)
                from: 10
                to: 190
                stepSize: 5
                onCommitted: ratio => HyprlandOptions.set("dwindle:default_split_ratio", ratio / 100)
            }
        }

        ContentSubsection {
            visible: root.layout === "master"
            title: Translation.tr("Master")

            StyledComboBox {
                buttonIcon: "open_with"
                textRole: "displayName"
                model: root.masterPlaces
                currentIndex: root.indexOfValue(root.masterPlaces, HyprlandOptions.text("master:new_status") || "slave")
                onActivated: index => HyprlandOptions.set("master:new_status", root.masterPlaces[index].value)
            }

            StyledComboBox {
                buttonIcon: "chevron_left"
                textRole: "displayName"
                model: root.masterSides
                currentIndex: root.indexOfValue(root.masterSides, HyprlandOptions.text("master:orientation") || "left")
                onActivated: index => HyprlandOptions.set("master:orientation", root.masterSides[index].value)
            }

            HyprlandSwitch {
                buttonIcon: "vertical_align_top"
                text: Translation.tr("New windows join at the top")
                option: "master:new_on_top"
            }

            OptionSpinBox {
                icon: "width"
                text: Translation.tr("Master takes (%)")
                current: Math.round(HyprlandOptions.number("master:mfact") * 100)
                from: 10
                to: 90
                stepSize: 5
                onCommitted: fraction => HyprlandOptions.set("master:mfact", fraction / 100)
            }
        }

        ContentSubsection {
            title: Translation.tr("Snapping")
            tooltip: Translation.tr("Applies to floating windows being dragged")

            HyprlandSwitch {
                buttonIcon: "grid_goldenratio"
                text: Translation.tr("Snap to other windows and to the screen")
                option: "general:snap:enabled"
            }

            ConfigRow {
                uniform: true

                OptionSpinBox {
                    enabled: HyprlandOptions.flag("general:snap:enabled")
                    icon: "width"
                    text: Translation.tr("To windows (px)")
                    current: HyprlandOptions.number("general:snap:window_gap")
                    from: 0
                    to: 100
                    stepSize: 1
                    onCommitted: gap => HyprlandOptions.set("general:snap:window_gap", gap)
                }

                OptionSpinBox {
                    enabled: HyprlandOptions.flag("general:snap:enabled")
                    icon: "fit_screen"
                    text: Translation.tr("To the screen (px)")
                    current: HyprlandOptions.number("general:snap:monitor_gap")
                    from: 0
                    to: 100
                    stepSize: 1
                    onCommitted: gap => HyprlandOptions.set("general:snap:monitor_gap", gap)
                }
            }
        }
    }

    ContentSection {
        icon: "overview_key"
        title: Translation.tr("Overview")

        ConfigSwitch {
            buttonIcon: "check"
            text: Translation.tr("Enable")
            checked: Config.options.overview.enable
            onCheckedChanged: {
                Config.options.overview.enable = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Looks")

            ConfigSwitch {
                buttonIcon: "center_focus_strong"
                text: Translation.tr("Center icons")
                checked: Config.options.overview.centerIcons
                onCheckedChanged: {
                    Config.options.overview.centerIcons = checked;
                }
            }
            ConfigSpinBox {
                icon: "loupe"
                text: Translation.tr("Scale (%)")
                value: Config.options.overview.scale * 100
                from: 1
                to: 100
                stepSize: 1
                onValueChanged: {
                    Config.options.overview.scale = value / 100;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Workspace grid")

            ConfigRow {
                uniform: true
                ConfigSpinBox {
                    icon: "splitscreen_bottom"
                    text: Translation.tr("Rows")
                    value: Config.options.overview.rows
                    from: 1
                    to: 20
                    stepSize: 1
                    onValueChanged: {
                        Config.options.overview.rows = value;
                    }
                }
                ConfigSpinBox {
                    icon: "splitscreen_right"
                    text: Translation.tr("Columns")
                    value: Config.options.overview.columns
                    from: 1
                    to: 20
                    stepSize: 1
                    onValueChanged: {
                        Config.options.overview.columns = value;
                    }
                }
            }
            ConfigRow {
                uniform: true
                ConfigSelectionArray {
                    currentValue: Config.options.overview.orderRightLeft
                    onSelected: newValue => {
                        Config.options.overview.orderRightLeft = newValue
                    }
                    options: [
                        {
                            displayName: Translation.tr("Left to right"),
                            icon: "arrow_forward",
                            value: 0
                        },
                        {
                            displayName: Translation.tr("Right to left"),
                            icon: "arrow_back",
                            value: 1
                        }
                    ]
                }
                ConfigSelectionArray {
                    currentValue: Config.options.overview.orderBottomUp
                    onSelected: newValue => {
                        Config.options.overview.orderBottomUp = newValue
                    }
                    options: [
                        {
                            displayName: Translation.tr("Top-down"),
                            icon: "arrow_downward",
                            value: 0
                        },
                        {
                            displayName: Translation.tr("Bottom-up"),
                            icon: "arrow_upward",
                            value: 1
                        }
                    ]
                }
            }
        }
    }

    ContentSection {
        icon: "select_window_2"
        title: Translation.tr("Workspaces")

        HyprlandSwitch {
            buttonIcon: "history"
            text: Translation.tr("Switching to the current workspace goes back to the last one")
            option: "binds:workspace_back_and_forth"
        }

        HyprlandSwitch {
            buttonIcon: "repeat"
            text: Translation.tr("Moving past the last workspace wraps around")
            option: "binds:allow_workspace_cycles"
        }

        HyprlandSwitch {
            buttonIcon: "animation"
            text: Translation.tr("Animate the wrap around")
            option: "animations:workspace_wraparound"
        }

        HyprlandSwitch {
            buttonIcon: "layers_clear"
            text: Translation.tr("Hide the special workspace when switching")
            option: "binds:hide_special_on_workspace_change"
        }

        HyprlandSwitch {
            buttonIcon: "close"
            text: Translation.tr("Close the special workspace once it is empty")
            option: "misc:close_special_on_empty"
        }

        ContentSubsection {
            title: Translation.tr("Swiping between workspaces")
            tooltip: Translation.tr("Which fingers do the swiping is set in the Hyprland configuration; these are the numbers behind it")

            ConfigRow {
                uniform: true

                OptionSpinBox {
                    icon: "swipe"
                    text: Translation.tr("Full swipe (px)")
                    current: HyprlandOptions.number("gestures:workspace_swipe_distance")
                    from: 100
                    to: 2000
                    stepSize: 50
                    onCommitted: distance => HyprlandOptions.set("gestures:workspace_swipe_distance", distance)
                }

                OptionSpinBox {
                    icon: "undo"
                    text: Translation.tr("Give up under (%)")
                    current: Math.round(HyprlandOptions.number("gestures:workspace_swipe_cancel_ratio") * 100)
                    from: 0
                    to: 100
                    stepSize: 5
                    onCommitted: ratio => HyprlandOptions.set("gestures:workspace_swipe_cancel_ratio", ratio / 100)
                }
            }

            OptionSpinBox {
                icon: "speed"
                text: Translation.tr("Flick speed that switches anyway")
                current: HyprlandOptions.number("gestures:workspace_swipe_min_speed_to_force")
                from: 0
                to: 100
                stepSize: 1
                onCommitted: speed => HyprlandOptions.set("gestures:workspace_swipe_min_speed_to_force", speed)
            }

            HyprlandSwitch {
                buttonIcon: "swap_horiz"
                text: Translation.tr("A swipe keeps the direction it started in")
                option: "gestures:workspace_swipe_direction_lock"
            }

            OptionSpinBox {
                enabled: HyprlandOptions.flag("gestures:workspace_swipe_direction_lock")
                icon: "straighten"
                text: Translation.tr("Locks after (px)")
                current: HyprlandOptions.number("gestures:workspace_swipe_direction_lock_threshold")
                from: 0
                to: 200
                stepSize: 5
                onCommitted: threshold => HyprlandOptions.set("gestures:workspace_swipe_direction_lock_threshold", threshold)
            }

            HyprlandSwitch {
                buttonIcon: "add_box"
                text: Translation.tr("Swiping past the last workspace makes a new one")
                option: "gestures:workspace_swipe_create_new"
            }

            HyprlandSwitch {
                buttonIcon: "all_inclusive"
                text: Translation.tr("Keep swiping without lifting the fingers")
                option: "gestures:workspace_swipe_forever"
            }
        }

        ContentSubsection {
            title: Translation.tr("Distance between workspaces")
            tooltip: Translation.tr("How far apart two workspaces sit while the switch is animating")

            OptionSpinBox {
                icon: "width"
                text: Translation.tr("Gap (px)")
                current: HyprlandOptions.number("general:gaps_workspaces")
                from: 0
                to: 500
                stepSize: 10
                onCommitted: gap => HyprlandOptions.set("general:gaps_workspaces", gap)
            }
        }
    }
}
