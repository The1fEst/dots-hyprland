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
                    },
                    {
                        displayName: Translation.tr("macOS"),
                        icon: "water_drop",
                        value: "macos"
                    }
                ]
            }
        }
    }

    ContentSection {
        icon: "grid_view"
        title: Translation.tr("Waffle panel")
        visible: Config.options.panelFamily === "waffle"

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
        icon: "water_drop"
        title: Translation.tr("macOS panel")
        visible: Config.options.panelFamily === "macos"

        ContentSubsection {
            title: Translation.tr("Liquid glass")
            tooltip: Translation.tr("Panels refract the wallpaper plus a live capture of the windows they cover. Drag the sample to move it around.")

            Loader {
                Layout.fillWidth: true
                Layout.preferredHeight: item?.implicitHeight ?? 0
                source: Qt.resolvedUrl("../macos/looks/MGlassPreview.qml")
            }

            ConfigSlider {
                text: Translation.tr("Tint")
                buttonIcon: "opacity"
                from: 0
                to: 100
                stopIndicatorValues: [40]
                value: Config.options.macos.glass.tintOpacity * 100
                onMoved: newValue => {
                    Config.options.macos.glass.tintOpacity = newValue / 100;
                }
            }
            ConfigSlider {
                text: Translation.tr("Blur")
                buttonIcon: "blur_on"
                usePercentTooltip: false
                from: 0
                to: 96
                stopIndicatorValues: [48]
                value: Config.options.macos.glass.blur
                onMoved: newValue => {
                    Config.options.macos.glass.blur = newValue;
                }
            }
            ConfigSlider {
                text: Translation.tr("Refraction")
                buttonIcon: "line_curve"
                from: 0
                to: 100
                stopIndicatorValues: [24]
                value: Config.options.macos.glass.refraction * 100
                onMoved: newValue => {
                    Config.options.macos.glass.refraction = newValue / 100;
                }
            }
            ConfigSlider {
                text: Translation.tr("Chromatic aberration")
                buttonIcon: "gradient"
                from: 0
                to: 100
                value: Config.options.macos.glass.chroma * 100
                onMoved: newValue => {
                    Config.options.macos.glass.chroma = newValue / 100;
                }
            }
            ConfigSlider {
                text: Translation.tr("Edge highlight")
                buttonIcon: "border_style"
                from: 0
                to: 100
                value: Config.options.macos.glass.edgeHighlight * 100
                onMoved: newValue => {
                    Config.options.macos.glass.edgeHighlight = newValue / 100;
                }
            }
            ConfigSlider {
                text: Translation.tr("Specular")
                buttonIcon: "wb_sunny"
                from: 0
                to: 100
                stopIndicatorValues: [21]
                value: Config.options.macos.glass.specular * 100
                onMoved: newValue => {
                    Config.options.macos.glass.specular = newValue / 100;
                }
            }
            ConfigSlider {
                text: Translation.tr("Fresnel")
                buttonIcon: "deblur"
                from: 0
                to: 100
                stopIndicatorValues: [84]
                value: Config.options.macos.glass.fresnel * 100
                onMoved: newValue => {
                    Config.options.macos.glass.fresnel = newValue / 100;
                }
            }
            ConfigSlider {
                text: Translation.tr("Distortion")
                buttonIcon: "waves"
                from: 0
                to: 100
                stopIndicatorValues: [3]
                value: Config.options.macos.glass.distortion * 100
                onMoved: newValue => {
                    Config.options.macos.glass.distortion = newValue / 100;
                }
            }
            ConfigSlider {
                text: Translation.tr("Z-radius")
                buttonIcon: "rounded_corner"
                usePercentTooltip: false
                from: 1
                to: 60
                stopIndicatorValues: [4]
                value: Config.options.macos.glass.zRadius
                onMoved: newValue => {
                    Config.options.macos.glass.zRadius = newValue;
                }
            }
            ConfigSlider {
                text: Translation.tr("Opacity")
                buttonIcon: "opacity"
                from: 0
                to: 100
                stopIndicatorValues: [100]
                value: Config.options.macos.glass.opacity * 100
                onMoved: newValue => {
                    Config.options.macos.glass.opacity = newValue / 100;
                }
            }
            ConfigSlider {
                text: Translation.tr("Saturation")
                buttonIcon: "palette"
                usePercentTooltip: false
                from: -100
                to: 100
                stopIndicatorValues: [0]
                value: Config.options.macos.glass.saturation * 100
                onMoved: newValue => {
                    Config.options.macos.glass.saturation = newValue / 100;
                }
            }
            ConfigSlider {
                text: Translation.tr("Brightness")
                buttonIcon: "brightness_6"
                usePercentTooltip: false
                from: -100
                to: 100
                stopIndicatorValues: [0]
                value: Config.options.macos.glass.brightness * 100
                onMoved: newValue => {
                    Config.options.macos.glass.brightness = newValue / 100;
                }
            }
            ConfigSlider {
                text: Translation.tr("Shadow opacity")
                buttonIcon: "shadow"
                from: 0
                to: 100
                stopIndicatorValues: [30]
                value: Config.options.macos.glass.shadowOpacity * 100
                onMoved: newValue => {
                    Config.options.macos.glass.shadowOpacity = newValue / 100;
                }
            }
            ConfigSlider {
                text: Translation.tr("Shadow spread")
                buttonIcon: "blur_linear"
                usePercentTooltip: false
                from: 0
                to: 60
                stopIndicatorValues: [10]
                value: Config.options.macos.glass.shadowSpread
                onMoved: newValue => {
                    Config.options.macos.glass.shadowSpread = newValue;
                }
            }
            ConfigSwitch {
                buttonIcon: "dome"
                text: Translation.tr("Dome bevel")
                checked: Config.options.macos.glass.bevelMode === 1
                onCheckedChanged: {
                    Config.options.macos.glass.bevelMode = checked ? 1 : 0;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Control centre")
            tooltip: Translation.tr("Comma-separated, in display order. Available: bluetooth, brightness, colorPicker, darkMode, idleInhibitor, media, mic, network, nightLight, screenSnip, volume")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("e.g. network, media, bluetooth, volume")
                text: (Config.options.macos.controlCenter.controls ?? []).join(", ")
                onEditingFinished: {
                    Config.options.macos.controlCenter.controls = StringUtils.splitList(text);
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Dock")

            ConfigSlider {
                text: Translation.tr("Icon size")
                buttonIcon: "photo_size_select_large"
                usePercentTooltip: false
                from: 24
                to: 96
                stopIndicatorValues: [57]
                value: Config.options.macos.dock.iconSize
                onMoved: newValue => {
                    Config.options.macos.dock.iconSize = Math.round(newValue);
                }
            }
            ConfigSlider {
                text: Translation.tr("Icon spacing")
                buttonIcon: "space_bar"
                usePercentTooltip: false
                from: 0
                to: 40
                stopIndicatorValues: [17]
                value: Config.options.macos.dock.iconSpacing
                onMoved: newValue => {
                    Config.options.macos.dock.iconSpacing = Math.round(newValue);
                }
            }
            ConfigSlider {
                text: Translation.tr("Icon radius")
                buttonIcon: "rounded_corner"
                usePercentTooltip: false
                from: 0
                to: 48
                stopIndicatorValues: [13]
                value: Config.options.macos.dock.iconRadius
                onMoved: newValue => {
                    Config.options.macos.dock.iconRadius = Math.round(newValue);
                }
            }
            ConfigSlider {
                text: Translation.tr("Side padding")
                buttonIcon: "width"
                usePercentTooltip: false
                from: 0
                to: 40
                stopIndicatorValues: [16]
                value: Config.options.macos.dock.paddingH
                onMoved: newValue => {
                    Config.options.macos.dock.paddingH = Math.round(newValue);
                }
            }
            ConfigSlider {
                text: Translation.tr("Top padding")
                buttonIcon: "height"
                usePercentTooltip: false
                from: 0
                to: 40
                stopIndicatorValues: [16]
                value: Config.options.macos.dock.paddingTop
                onMoved: newValue => {
                    Config.options.macos.dock.paddingTop = Math.round(newValue);
                }
            }
            ConfigSlider {
                text: Translation.tr("Corner radius")
                buttonIcon: "rounded_corner"
                usePercentTooltip: false
                from: 0
                to: 48
                stopIndicatorValues: [28]
                value: Config.options.macos.dock.radius
                onMoved: newValue => {
                    Config.options.macos.dock.radius = Math.round(newValue);
                }
            }
            ConfigSlider {
                text: Translation.tr("Bottom margin")
                buttonIcon: "vertical_align_bottom"
                usePercentTooltip: false
                from: 0
                to: 40
                stopIndicatorValues: [6]
                value: Config.options.macos.dock.bottomMargin
                onMoved: newValue => {
                    Config.options.macos.dock.bottomMargin = Math.round(newValue);
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
