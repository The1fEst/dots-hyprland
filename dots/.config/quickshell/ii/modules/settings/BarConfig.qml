import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "notifications"
        title: Translation.tr("Notifications")
        ConfigSwitch {
            buttonIcon: "counter_2"
            text: Translation.tr("Unread indicator: show count")
            checked: Config.options.bar.indicators.notifications.showUnreadCount
            onCheckedChanged: {
                Config.options.bar.indicators.notifications.showUnreadCount = checked;
            }
        }
    }
    
    ContentSection {
        icon: "spoke"
        title: Translation.tr("Positioning")

        ConfigRow {
            ContentSubsection {
                title: Translation.tr("Bar position")
                Layout.fillWidth: true

                ConfigSelectionArray {
                    currentValue: (Config.options.bar.bottom ? 1 : 0) | (Config.options.bar.vertical ? 2 : 0)
                    onSelected: newValue => {
                        Config.options.bar.bottom = (newValue & 1) !== 0;
                        Config.options.bar.vertical = (newValue & 2) !== 0;
                    }
                    options: [
                        {
                            displayName: Translation.tr("Top"),
                            icon: "arrow_upward",
                            value: 0 // bottom: false, vertical: false
                        },
                        {
                            displayName: Translation.tr("Left"),
                            icon: "arrow_back",
                            value: 2 // bottom: false, vertical: true
                        },
                        {
                            displayName: Translation.tr("Bottom"),
                            icon: "arrow_downward",
                            value: 1 // bottom: true, vertical: false
                        },
                        {
                            displayName: Translation.tr("Right"),
                            icon: "arrow_forward",
                            value: 3 // bottom: true, vertical: true
                        }
                    ]
                }
            }
            ContentSubsection {
                title: Translation.tr("Automatically hide")
                Layout.fillWidth: false

                ConfigSelectionArray {
                    currentValue: Config.options.bar.autoHide.enable
                    onSelected: newValue => {
                        Config.options.bar.autoHide.enable = newValue; // Update local copy
                    }
                    options: [
                        {
                            displayName: Translation.tr("No"),
                            icon: "close",
                            value: false
                        },
                        {
                            displayName: Translation.tr("Yes"),
                            icon: "check",
                            value: true
                        }
                    ]
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Auto-hide behavior")
            enabled: Config.options.bar.autoHide.enable

            ConfigRow {
                uniform: true
                ConfigSwitch {
                    buttonIcon: "move_down"
                    text: Translation.tr("Push windows away")
                    checked: Config.options.bar.autoHide.pushWindows
                    onCheckedChanged: {
                        Config.options.bar.autoHide.pushWindows = checked;
                    }
                    StyledToolTip {
                        text: Translation.tr("Reserve space for the bar even when it's hidden")
                    }
                }
                ConfigSwitch {
                    buttonIcon: "keyboard_command_key"
                    text: Translation.tr("Show when pressing Super")
                    checked: Config.options.bar.autoHide.showWhenPressingSuper.enable
                    onCheckedChanged: {
                        Config.options.bar.autoHide.showWhenPressingSuper.enable = checked;
                    }
                }
            }
            ConfigSpinBox {
                icon: "touch_long"
                text: Translation.tr("Super press delay (ms)")
                enabled: Config.options.bar.autoHide.showWhenPressingSuper.enable
                value: Config.options.bar.autoHide.showWhenPressingSuper.delay
                from: 0
                to: 1000
                stepSize: 20
                onValueChanged: {
                    Config.options.bar.autoHide.showWhenPressingSuper.delay = value;
                }
            }
            ConfigSpinBox {
                icon: "width"
                text: Translation.tr("Hover region thickness (px)")
                value: Config.options.bar.autoHide.hoverRegionWidth
                from: 1
                to: 50
                stepSize: 1
                onValueChanged: {
                    Config.options.bar.autoHide.hoverRegionWidth = value;
                }
            }
        }

        ConfigRow {

            ContentSubsection {
                title: Translation.tr("Corner style")
                Layout.fillWidth: true

                ConfigSelectionArray {
                    currentValue: Config.options.bar.cornerStyle
                    onSelected: newValue => {
                        Config.options.bar.cornerStyle = newValue; // Update local copy
                    }
                    options: [
                        {
                            displayName: Translation.tr("Hug"),
                            icon: "line_curve",
                            value: 0
                        },
                        {
                            displayName: Translation.tr("Float"),
                            icon: "page_header",
                            value: 1
                        },
                        {
                            displayName: Translation.tr("Rect"),
                            icon: "toolbar",
                            value: 2
                        }
                    ]
                }
            }

            ContentSubsection {
                title: Translation.tr("Group style")
                Layout.fillWidth: false

                ConfigSelectionArray {
                    currentValue: Config.options.bar.borderless
                    onSelected: newValue => {
                        Config.options.bar.borderless = newValue; // Update local copy
                    }
                    options: [
                        {
                            displayName: Translation.tr("Pills"),
                            icon: "location_chip",
                            value: false
                        },
                        {
                            displayName: Translation.tr("Line-separated"),
                            icon: "split_scene",
                            value: true
                        }
                    ]
                }
            }
        }
    }

    ContentSection {
        icon: "format_paint"
        title: Translation.tr("Appearance")

        ConfigSwitch {
            buttonIcon: "rectangle"
            text: Translation.tr("Show background")
            checked: Config.options.bar.showBackground
            onCheckedChanged: {
                Config.options.bar.showBackground = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "ev_shadow"
            text: Translation.tr("Shadow when floating")
            enabled: Config.options.bar.showBackground && Config.options.bar.cornerStyle === 1
            checked: Config.options.bar.floatStyleShadow
            onCheckedChanged: {
                Config.options.bar.floatStyleShadow = checked;
            }
            StyledToolTip {
                text: Translation.tr("Only applies with the Float corner style")
            }
        }

        ConfigSwitch {
            buttonIcon: "notes"
            text: Translation.tr("Verbose")
            checked: Config.options.bar.verbose
            onCheckedChanged: {
                Config.options.bar.verbose = checked;
            }
            StyledToolTip {
                text: Translation.tr("Shows the date next to the clock and the utility buttons")
            }
        }

        ContentSubsection {
            title: Translation.tr("Monitors")
            tooltip: Translation.tr("Comma-separated monitor names (see 'hyprctl monitors'). Leave empty to show the bar everywhere.")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("e.g. eDP-1, HDMI-A-1")
                text: (Config.options.bar.screenList ?? []).join(", ")
                onEditingFinished: {
                    Config.options.bar.screenList = StringUtils.splitList(text);
                }
            }
        }
    }

    ContentSection {
        icon: "memory"
        title: Translation.tr("Resources")

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "memory_alt"
                text: Translation.tr("Always show swap")
                checked: Config.options.bar.resources.alwaysShowSwap
                onCheckedChanged: {
                    Config.options.bar.resources.alwaysShowSwap = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "memory"
                text: Translation.tr("Always show CPU")
                checked: Config.options.bar.resources.alwaysShowCpu
                onCheckedChanged: {
                    Config.options.bar.resources.alwaysShowCpu = checked;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Warning thresholds (%)")

            ConfigSpinBox {
                icon: "memory"
                text: Translation.tr("Memory")
                value: Config.options.bar.resources.memoryWarningThreshold
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.bar.resources.memoryWarningThreshold = value;
                }
            }
            ConfigSpinBox {
                icon: "memory_alt"
                text: Translation.tr("Swap")
                value: Config.options.bar.resources.swapWarningThreshold
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.bar.resources.swapWarningThreshold = value;
                }
            }
            ConfigSpinBox {
                icon: "speed"
                text: Translation.tr("CPU")
                value: Config.options.bar.resources.cpuWarningThreshold
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.bar.resources.cpuWarningThreshold = value;
                }
            }
        }
    }

    ContentSection {
        icon: "shelf_auto_hide"
        title: Translation.tr("Tray")

        ConfigSwitch {
            buttonIcon: "keep"
            text: Translation.tr('Make icons pinned by default')
            checked: Config.options.tray.invertPinnedItems
            onCheckedChanged: {
                Config.options.tray.invertPinnedItems = checked;
            }
        }
        
        ConfigSwitch {
            buttonIcon: "colors"
            text: Translation.tr('Tint icons')
            checked: Config.options.tray.monochromeIcons
            onCheckedChanged: {
                Config.options.tray.monochromeIcons = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "visibility_off"
            text: Translation.tr('Hide passive items')
            checked: Config.options.tray.filterPassive
            onCheckedChanged: {
                Config.options.tray.filterPassive = checked;
            }
            StyledToolTip {
                text: Translation.tr("Hides tray items that report themselves as passive")
            }
        }

        ConfigSwitch {
            buttonIcon: "id_card"
            text: Translation.tr('Show item IDs in tooltips')
            checked: Config.options.tray.showItemId
            onCheckedChanged: {
                Config.options.tray.showItemId = checked;
            }
            StyledToolTip {
                text: Translation.tr("Useful for finding out what to type below")
            }
        }

        ContentSubsection {
            title: Config.options.tray.invertPinnedItems ? Translation.tr("Unpinned items") : Translation.tr("Pinned items")
            tooltip: Translation.tr("Comma-separated tray item IDs")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("e.g. Fcitx, steam")
                text: (Config.options.tray.pinnedItems ?? []).join(", ")
                onEditingFinished: {
                    Config.options.tray.pinnedItems = StringUtils.splitList(text);
                }
            }
        }
    }

    ContentSection {
        icon: "widgets"
        title: Translation.tr("Utility buttons")

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "content_cut"
                text: Translation.tr("Screen snip")
                checked: Config.options.bar.utilButtons.showScreenSnip
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showScreenSnip = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "colorize"
                text: Translation.tr("Color picker")
                checked: Config.options.bar.utilButtons.showColorPicker
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showColorPicker = checked;
                }
            }
        }
        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "keyboard"
                text: Translation.tr("Keyboard toggle")
                checked: Config.options.bar.utilButtons.showKeyboardToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showKeyboardToggle = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "mic"
                text: Translation.tr("Mic toggle")
                checked: Config.options.bar.utilButtons.showMicToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showMicToggle = checked;
                }
            }
        }
        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "dark_mode"
                text: Translation.tr("Dark/Light toggle")
                checked: Config.options.bar.utilButtons.showDarkModeToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showDarkModeToggle = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "speed"
                text: Translation.tr("Performance Profile toggle")
                checked: Config.options.bar.utilButtons.showPerformanceProfileToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showPerformanceProfileToggle = checked;
                }
            }
        }
        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "videocam"
                text: Translation.tr("Record")
                checked: Config.options.bar.utilButtons.showScreenRecord
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showScreenRecord = checked;
                }
            }
        }
    }

    ContentSection {
        icon: "cloud"
        title: Translation.tr("Weather")
        ConfigSwitch {
            buttonIcon: "check"
            text: Translation.tr("Enable")
            checked: Config.options.bar.weather.enable
            onCheckedChanged: {
                Config.options.bar.weather.enable = checked;
            }
        }
    }

    ContentSection {
        icon: "workspaces"
        title: Translation.tr("Workspaces")

        ConfigSwitch {
            buttonIcon: "counter_1"
            text: Translation.tr('Always show numbers')
            checked: Config.options.bar.workspaces.alwaysShowNumbers
            onCheckedChanged: {
                Config.options.bar.workspaces.alwaysShowNumbers = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "award_star"
            text: Translation.tr('Show app icons')
            checked: Config.options.bar.workspaces.showAppIcons
            onCheckedChanged: {
                Config.options.bar.workspaces.showAppIcons = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "colors"
            text: Translation.tr('Tint app icons')
            checked: Config.options.bar.workspaces.monochromeIcons
            onCheckedChanged: {
                Config.options.bar.workspaces.monochromeIcons = checked;
            }
        }

        ConfigSwitch {
            buttonIcon: "font_download"
            text: Translation.tr('Nerd Font for workspace numbers')
            checked: Config.options.bar.workspaces.useNerdFont
            onCheckedChanged: {
                Config.options.bar.workspaces.useNerdFont = checked;
            }
            StyledToolTip {
                text: Translation.tr("Renders workspace numbers with your Nerd Font instead of the main one")
            }
        }

        ConfigSpinBox {
            icon: "view_column"
            text: Translation.tr("Workspaces shown")
            value: Config.options.bar.workspaces.shown
            from: 1
            to: 30
            stepSize: 1
            onValueChanged: {
                Config.options.bar.workspaces.shown = value;
            }
        }

        ContentSubsection {
            title: Translation.tr("Number style")

            ConfigSelectionArray {
                currentValue: JSON.stringify(Config.options.bar.workspaces.numberMap)
                onSelected: newValue => {
                    Config.options.bar.workspaces.numberMap = JSON.parse(newValue)
                }
                options: [
                    {
                        displayName: Translation.tr("Normal"),
                        icon: "timer_10",
                        value: '[]'
                    },
                    {
                        displayName: Translation.tr("Han chars"),
                        icon: "square_dot",
                        value: '["一","二","三","四","五","六","七","八","九","十","十一","十二","十三","十四","十五","十六","十七","十八","十九","二十"]'
                    },
                    {
                        displayName: Translation.tr("Roman"),
                        icon: "account_balance",
                        value: '["I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII","XIII","XIV","XV","XVI","XVII","XVIII","XIX","XX"]'
                    }
                ]
            }
        }
    }

    ContentSection {
        icon: "tooltip"
        title: Translation.tr("Tooltips")
        ConfigSwitch {
            buttonIcon: "ads_click"
            text: Translation.tr("Click to show")
            checked: Config.options.bar.tooltips.clickToShow
            onCheckedChanged: {
                Config.options.bar.tooltips.clickToShow = checked;
            }
        }
    }
}
