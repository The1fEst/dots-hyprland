import "../ii/onScreenKeyboard/layouts.js" as OskLayouts
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "call_to_action"
        title: Translation.tr("Dock")

        ConfigSwitch {
            buttonIcon: "check"
            text: Translation.tr("Enable")
            checked: Config.options.dock.enable
            onCheckedChanged: {
                Config.options.dock.enable = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Reveal")

            ConfigRow {
                uniform: true
                ConfigSwitch {
                    buttonIcon: "highlight_mouse_cursor"
                    text: Translation.tr("Hover to reveal")
                    checked: Config.options.dock.hoverToReveal
                    onCheckedChanged: {
                        Config.options.dock.hoverToReveal = checked;
                    }
                }
                ConfigSwitch {
                    buttonIcon: "keep"
                    text: Translation.tr("Pinned on startup")
                    checked: Config.options.dock.pinnedOnStartup
                    onCheckedChanged: {
                        Config.options.dock.pinnedOnStartup = checked;
                    }
                }
            }

            ConfigSpinBox {
                icon: "highlight_mouse_cursor"
                text: Translation.tr("Hover region height (px)")
                enabled: Config.options.dock.hoverToReveal
                value: Config.options.dock.hoverRegionHeight
                from: 1
                to: 50
                stepSize: 1
                onValueChanged: {
                    Config.options.dock.hoverRegionHeight = value;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Looks")

            ConfigSwitch {
                buttonIcon: "colors"
                text: Translation.tr("Tint app icons")
                checked: Config.options.dock.monochromeIcons
                onCheckedChanged: {
                    Config.options.dock.monochromeIcons = checked;
                }
            }

            ConfigSpinBox {
                icon: "height"
                text: Translation.tr("Height (px)")
                value: Config.options.dock.height
                from: 30
                to: 150
                stepSize: 5
                onValueChanged: {
                    Config.options.dock.height = value;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Pinned apps")
            tooltip: Translation.tr("Comma-separated desktop entry IDs, in the order they should appear")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("e.g. org.kde.dolphin, kitty")
                text: (Config.options.dock.pinnedApps ?? []).join(", ")
                onEditingFinished: {
                    Config.options.dock.pinnedApps = StringUtils.splitList(text);
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Ignored apps")
            tooltip: Translation.tr("Comma-separated regexes. Matching windows won't get a dock entry.")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("e.g. ^steam_app_.*")
                text: (Config.options.dock.ignoredAppRegexes ?? []).join(", ")
                onEditingFinished: {
                    Config.options.dock.ignoredAppRegexes = StringUtils.splitList(text);
                }
            }
        }
    }

    ContentSection {
        icon: "side_navigation"
        title: Translation.tr("Sidebars")

        ConfigSwitch {
            buttonIcon: "memory"
            text: Translation.tr('Keep right sidebar loaded')
            checked: Config.options.sidebar.keepRightSidebarLoaded
            onCheckedChanged: {
                Config.options.sidebar.keepRightSidebarLoaded = checked;
            }
            StyledToolTip {
                text: Translation.tr("When enabled keeps the content of the right sidebar loaded to reduce the delay when opening,\nat the cost of around 15MB of consistent RAM usage. Delay significance depends on your system's performance.\nUsing a custom kernel like linux-cachyos might help")
            }
        }

        ContentSubsection {
            title: Translation.tr("Quick toggles")
            tooltip: Translation.tr("Which toggles are shown, their size and their order are edited in the sidebar itself, with its edit mode")

            ConfigSelectionArray {
                Layout.fillWidth: false
                currentValue: Config.options.sidebar.quickToggles.style
                onSelected: newValue => {
                    Config.options.sidebar.quickToggles.style = newValue;
                }
                options: [
                    {
                        displayName: Translation.tr("Classic"),
                        icon: "password_2",
                        value: "classic"
                    },
                    {
                        displayName: Translation.tr("Android"),
                        icon: "action_key",
                        value: "android"
                    }
                ]
            }

            ConfigSpinBox {
                enabled: Config.options.sidebar.quickToggles.style === "android"
                icon: "splitscreen_left"
                text: Translation.tr("Columns")
                value: Config.options.sidebar.quickToggles.android.columns
                from: 1
                to: 8
                stepSize: 1
                onValueChanged: {
                    Config.options.sidebar.quickToggles.android.columns = value;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Sliders")

            ConfigSwitch {
                buttonIcon: "check"
                text: Translation.tr("Enable")
                checked: Config.options.sidebar.quickSliders.enable
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.enable = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "brightness_6"
                text: Translation.tr("Brightness")
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showBrightness
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.showBrightness = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "volume_up"
                text: Translation.tr("Volume")
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showVolume
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.showVolume = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "mic"
                text: Translation.tr("Microphone")
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showMic
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.showMic = checked;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Corner open")
            tooltip: Translation.tr("Allows you to open sidebars by clicking or hovering screen corners regardless of bar position")
            ConfigRow {
                uniform: true
                ConfigSwitch {
                    buttonIcon: "check"
                    text: Translation.tr("Enable")
                    checked: Config.options.sidebar.cornerOpen.enable
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.enable = checked;
                    }
                }
            }
            ConfigSwitch {
                buttonIcon: "highlight_mouse_cursor"
                text: Translation.tr("Hover to trigger")
                checked: Config.options.sidebar.cornerOpen.clickless
                onCheckedChanged: {
                    Config.options.sidebar.cornerOpen.clickless = checked;
                }

                StyledToolTip {
                    text: Translation.tr("When this is off you'll have to click")
                }
            }
            Row {
                ConfigSwitch {
                    enabled: !Config.options.sidebar.cornerOpen.clickless
                    text: Translation.tr("Force hover open at absolute corner")
                    checked: Config.options.sidebar.cornerOpen.clicklessCornerEnd
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.clicklessCornerEnd = checked;
                    }

                    StyledToolTip {
                        text: Translation.tr("When the previous option is off and this is on,\nyou can still hover the corner's end to open sidebar,\nand the remaining area can be used for volume/brightness scroll")
                    }
                }
                ConfigSpinBox {
                    icon: "arrow_cool_down"
                    text: Translation.tr("with vertical offset")
                    value: Config.options.sidebar.cornerOpen.clicklessCornerVerticalOffset
                    from: 0
                    to: 20
                    stepSize: 1
                    onValueChanged: {
                        Config.options.sidebar.cornerOpen.clicklessCornerVerticalOffset = value;
                    }
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        StyledToolTip {
                            extraVisibleCondition: mouseArea.containsMouse
                            text: Translation.tr("Why this is cool:\nFor non-0 values, it won't trigger when you reach the\nscreen corner along the horizontal edge, but it will when\nyou do along the vertical edge")
                        }
                    }
                }
            }

            ConfigRow {
                uniform: true
                ConfigSwitch {
                    buttonIcon: "vertical_align_bottom"
                    text: Translation.tr("Place at bottom")
                    checked: Config.options.sidebar.cornerOpen.bottom
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.bottom = checked;
                    }

                    StyledToolTip {
                        text: Translation.tr("Place the corners to trigger at the bottom")
                    }
                }
                ConfigSwitch {
                    buttonIcon: "unfold_more_double"
                    text: Translation.tr("Value scroll")
                    checked: Config.options.sidebar.cornerOpen.valueScroll
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.valueScroll = checked;
                    }

                    StyledToolTip {
                        text: Translation.tr("Brightness and volume")
                    }
                }
            }
            ConfigSwitch {
                buttonIcon: "visibility"
                text: Translation.tr("Visualize region")
                checked: Config.options.sidebar.cornerOpen.visualize
                onCheckedChanged: {
                    Config.options.sidebar.cornerOpen.visualize = checked;
                }
            }
            ConfigRow {
                ConfigSpinBox {
                    icon: "arrow_range"
                    text: Translation.tr("Region width")
                    value: Config.options.sidebar.cornerOpen.cornerRegionWidth
                    from: 1
                    to: 300
                    stepSize: 1
                    onValueChanged: {
                        Config.options.sidebar.cornerOpen.cornerRegionWidth = value;
                    }
                }
                ConfigSpinBox {
                    icon: "height"
                    text: Translation.tr("Region height")
                    value: Config.options.sidebar.cornerOpen.cornerRegionHeight
                    from: 1
                    to: 300
                    stepSize: 1
                    onValueChanged: {
                        Config.options.sidebar.cornerOpen.cornerRegionHeight = value;
                    }
                }
            }
        }
    }


    ContentSection {
        icon: "apps"
        title: Translation.tr("Launcher")

        ContentSubsection {
            title: Translation.tr("Pinned apps")
            tooltip: Translation.tr("Comma-separated desktop entry IDs shown when the search field is empty")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("e.g. org.kde.dolphin, kitty")
                text: (Config.options.launcher.pinnedApps ?? []).join(", ")
                onEditingFinished: {
                    Config.options.launcher.pinnedApps = StringUtils.splitList(text);
                }
            }
        }
    }

    ContentSection {
        icon: "wallpaper_slideshow"
        title: Translation.tr("Wallpaper selector")

        ConfigSwitch {
            buttonIcon: "ad"
            text: Translation.tr('Use system file picker')
            checked: Config.options.wallpaperSelector.useSystemFileDialog
            onCheckedChanged: {
                Config.options.wallpaperSelector.useSystemFileDialog = checked;
            }
        }
    }

    ContentSection {
        icon: "keyboard"
        title: Translation.tr("On-screen keyboard")

        ConfigSwitch {
            buttonIcon: "keep"
            text: Translation.tr("Pinned on startup")
            checked: Config.options.osk.pinnedOnStartup
            onCheckedChanged: {
                Config.options.osk.pinnedOnStartup = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Layout")

            StyledComboBox {
                id: oskLayoutSelector
                buttonIcon: "keyboard_alt"
                readonly property var layoutNames: Object.keys(OskLayouts.byName)

                model: layoutNames
                currentIndex: {
                    const index = layoutNames.indexOf(Config.options.osk.layout);
                    return index !== -1 ? index : 0;
                }
                onActivated: index => {
                    Config.options.osk.layout = layoutNames[index];
                }
            }
        }
    }

    ContentSection {
        icon: "keyboard_keys"
        title: Translation.tr("Cheat sheet")

        ContentSubsection {
            title: Translation.tr("Super key symbol")
            tooltip: Translation.tr("You can also manually edit cheatsheet.superKey")
            ConfigSelectionArray {
                currentValue: Config.options.cheatsheet.superKey
                onSelected: newValue => {
                    Config.options.cheatsheet.superKey = newValue;
                }
                options: ([
                  "󰖳", "", "󰨡", "", "󰌽", "󰣇", "", "", "",
                  "", "", "󱄛", "", "", "", "⌘", "󰀲", "󰟍", ""
                ]).map(icon => { return {
                  displayName: icon,
                  value: icon
                  }
                })
            }
        }

        ContentSubsection {
            title: Translation.tr("Symbols")

            ConfigSwitch {
                buttonIcon: "󰘵"
                text: Translation.tr("Use macOS-like symbols for mods keys")
                checked: Config.options.cheatsheet.useMacSymbol
                onCheckedChanged: {
                    Config.options.cheatsheet.useMacSymbol = checked;
                }
                StyledToolTip {
                    text: Translation.tr("e.g. 󰘴  for Ctrl, 󰘵  for Alt, 󰘶  for Shift, etc")
                }
            }

            ConfigSwitch {
                buttonIcon: "󱊶"
                text: Translation.tr("Use symbols for function keys")
                checked: Config.options.cheatsheet.useFnSymbol
                onCheckedChanged: {
                    Config.options.cheatsheet.useFnSymbol = checked;
                }
                StyledToolTip {
                  text: Translation.tr("e.g. 󱊫 for F1, 󱊶  for F12")
                }
            }
            ConfigSwitch {
                buttonIcon: "󰍽"
                text: Translation.tr("Use symbols for mouse")
                checked: Config.options.cheatsheet.useMouseSymbol
                onCheckedChanged: {
                    Config.options.cheatsheet.useMouseSymbol = checked;
                }
                StyledToolTip {
                  text: Translation.tr("Replace 󱕐   for \"Scroll ↓\", 󱕑   \"Scroll ↑\", L󰍽   \"LMB\", R󰍽   \"RMB\", 󱕒   \"Scroll ↑/↓\" and ⇞/⇟ for \"Page_↑/↓\"")
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Keycaps")

            ConfigSwitch {
                buttonIcon: "highlight_keyboard_focus"
                text: Translation.tr("Split buttons")
                checked: Config.options.cheatsheet.splitButtons
                onCheckedChanged: {
                    Config.options.cheatsheet.splitButtons = checked;
                }
                StyledToolTip {
                    text: Translation.tr("Display modifiers and keys in multiple keycap (e.g., \"Ctrl + A\" instead of \"Ctrl A\" or \"󰘴 + A\" instead of \"󰘴 A\")")
                }
            }

            ConfigRow {
                uniform: true
                ConfigSpinBox {
                    text: Translation.tr("Keybind font size")
                    value: Config.options.cheatsheet.fontSize.key
                    from: 8
                    to: 30
                    stepSize: 1
                    onValueChanged: {
                        Config.options.cheatsheet.fontSize.key = value;
                    }
                }
                ConfigSpinBox {
                    text: Translation.tr("Description font size")
                    value: Config.options.cheatsheet.fontSize.comment
                    from: 8
                    to: 30
                    stepSize: 1
                    onValueChanged: {
                        Config.options.cheatsheet.fontSize.comment = value;
                    }
                }
            }
        }
    }
}
