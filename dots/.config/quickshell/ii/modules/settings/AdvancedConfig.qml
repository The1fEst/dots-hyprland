import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "dashboard"
        title: Translation.tr("Panel family")

        ContentSubsection {
            title: Translation.tr("Style of the whole shell")
            tooltip: Translation.tr("Switching reloads every panel. Also bound to a keybind and the 'panelFamily cycle' IPC call.")

            ConfigSelectionArray {
                currentValue: Config.options.panelFamily
                onSelected: newValue => {
                    Config.options.panelFamily = newValue;
                }
                options: [
                    {
                        displayName: Translation.tr("illogical-impulse"),
                        icon: "toast",
                        value: "ii"
                    },
                    {
                        displayName: Translation.tr("Waffle"),
                        icon: "grid_view",
                        value: "waffle"
                    }
                ]
            }
        }
    }

    ContentSection {
        icon: "grid_view"
        title: Translation.tr("Waffle panel")

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "arrow_downward"
                text: Translation.tr("Bar at the bottom")
                checked: Config.options.waffles.bar.bottom
                onCheckedChanged: {
                    Config.options.waffles.bar.bottom = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "format_align_left"
                text: Translation.tr("Left-align apps")
                checked: Config.options.waffles.bar.leftAlignApps
                onCheckedChanged: {
                    Config.options.waffles.bar.leftAlignApps = checked;
                }
            }
        }

        ConfigSwitch {
            buttonIcon: "calendar_view_week"
            text: Translation.tr("Two-character weekday names")
            checked: Config.options.waffles.calendar.force2CharDayOfWeek
            onCheckedChanged: {
                Config.options.waffles.calendar.force2CharDayOfWeek = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Action center toggles")
            tooltip: Translation.tr("Comma-separated, in display order. Available: bluetooth, cloudflareWarp, colorPicker, darkMode, easyEffects, idleInhibitor, mic, network, nightLight, notifications, onScreenKeyboard, powerProfile, screenSnip")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("e.g. network, bluetooth, nightLight")
                text: (Config.options.waffles.actionCenter.toggles ?? []).join(", ")
                onEditingFinished: {
                    Config.options.waffles.actionCenter.toggles = StringUtils.splitList(text);
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Tweaks")
            tooltip: Translation.tr("Turning these off makes the panel behave more like the thing it imitates, quirks included")

            ConfigSwitch {
                buttonIcon: "toggle_on"
                text: Translation.tr("Fix switch handle position")
                checked: Config.options.waffles.tweaks.switchHandlePositionFix
                onCheckedChanged: {
                    Config.options.waffles.tweaks.switchHandlePositionFix = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "animation"
                text: Translation.tr("Smoother menu animations")
                checked: Config.options.waffles.tweaks.smootherMenuAnimations
                onCheckedChanged: {
                    Config.options.waffles.tweaks.smootherMenuAnimations = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "search"
                text: Translation.tr("Smoother search bar")
                checked: Config.options.waffles.tweaks.smootherSearchBar
                onCheckedChanged: {
                    Config.options.waffles.tweaks.smootherSearchBar = checked;
                }
            }
        }
    }

    ContentSection {
        icon: "colors"
        title: Translation.tr("Color generation")

        ConfigSwitch {
            buttonIcon: "hardware"
            text: Translation.tr("Shell & utilities")
            checked: Config.options.appearance.wallpaperTheming.enableAppsAndShell
            onCheckedChanged: {
                Config.options.appearance.wallpaperTheming.enableAppsAndShell = checked;
            }
        }
        ConfigSwitch {
            buttonIcon: "tv_options_input_settings"
            text: Translation.tr("Qt apps")
            checked: Config.options.appearance.wallpaperTheming.enableQtApps
            onCheckedChanged: {
                Config.options.appearance.wallpaperTheming.enableQtApps = checked;
            }
            StyledToolTip {
                text: Translation.tr("Shell & utilities theming must also be enabled")
            }
        }
        ConfigSwitch {
            buttonIcon: "terminal"
            text: Translation.tr("Terminal")
            checked: Config.options.appearance.wallpaperTheming.enableTerminal
            onCheckedChanged: {
                Config.options.appearance.wallpaperTheming.enableTerminal = checked;
            }
            StyledToolTip {
                text: Translation.tr("Shell & utilities theming must also be enabled")
            }
        }
        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "dark_mode"
                text: Translation.tr("Force dark mode in terminal")
                checked: Config.options.appearance.wallpaperTheming.terminalGenerationProps.forceDarkMode
                onCheckedChanged: {
                     Config.options.appearance.wallpaperTheming.terminalGenerationProps.forceDarkMode= checked;
                }
                StyledToolTip {
                    text: Translation.tr("Ignored if terminal theming is not enabled")
                }
            }
        }

        ConfigSpinBox {
            icon: "invert_colors"
            text: Translation.tr("Terminal: Harmony (%)")
            value: Config.options.appearance.wallpaperTheming.terminalGenerationProps.harmony * 100
            from: 0
            to: 100
            stepSize: 10
            onValueChanged: {
                Config.options.appearance.wallpaperTheming.terminalGenerationProps.harmony = value / 100;
            }
        }
        ConfigSpinBox {
            icon: "gradient"
            text: Translation.tr("Terminal: Harmonize threshold")
            value: Config.options.appearance.wallpaperTheming.terminalGenerationProps.harmonizeThreshold
            from: 0
            to: 100
            stepSize: 10
            onValueChanged: {
                Config.options.appearance.wallpaperTheming.terminalGenerationProps.harmonizeThreshold = value;
            }
        }
        ConfigSpinBox {
            icon: "format_color_text"
            text: Translation.tr("Terminal: Foreground boost (%)")
            value: Config.options.appearance.wallpaperTheming.terminalGenerationProps.termFgBoost * 100
            from: 0
            to: 100
            stepSize: 10
            onValueChanged: {
                Config.options.appearance.wallpaperTheming.terminalGenerationProps.termFgBoost = value / 100;
            }
        }
    }

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
