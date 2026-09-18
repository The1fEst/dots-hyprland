import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    readonly property int fontLabelWidth: 110

    readonly property list<var> fontRoles: [
        {
            role: "general",
            shellKeys: ["main", "numbers", "reading"],
            name: Translation.tr("General")
        },
        {
            role: "fixed",
            shellKeys: ["monospace"],
            name: Translation.tr("Fixed width")
        },
        {
            role: "title",
            shellKeys: ["title"],
            name: Translation.tr("Titles")
        },
        {
            role: "small",
            shellKeys: [],
            name: Translation.tr("Small")
        },
        {
            role: "toolbar",
            shellKeys: [],
            name: Translation.tr("Toolbar")
        },
        {
            role: "menu",
            shellKeys: [],
            name: Translation.tr("Menu")
        }
    ]

    readonly property list<var> shellOnlyFontRoles: [
        {
            key: "iconNerd",
            name: Translation.tr("Nerd icons")
        },
        {
            key: "expressive",
            name: Translation.tr("Expressive")
        }
    ]

    function named(values: var): var {
        return values.map(value => ({
                    displayName: value,
                    value: value
                }));
    }

    function familyOptions(current: string): var {
        const families = DesktopAppearance.familyNames;
        if (current.length === 0 || families.includes(current))
            return root.named(families);
        return root.named([current, ...families]);
    }

    property string bulkFamily: DesktopAppearance.fonts["general"]?.family ?? ""
    property int bulkSize: DesktopAppearance.fonts["general"]?.size ?? 10
    property bool bulkChangesFamily: true
    property bool bulkChangesSize: false

    readonly property list<string> bulkShellKeys: ["main", "numbers", "reading", "title"]

    function adjustAll(): void {
        const parts = ({});
        if (root.bulkChangesFamily && root.bulkFamily.length > 0)
            parts.family = root.bulkFamily;
        if (root.bulkChangesSize)
            parts.size = root.bulkSize;
        if (Object.keys(parts).length === 0)
            return;
        DesktopAppearance.setFont("all", parts);
        if (parts.family === undefined)
            return;
        for (const key of root.bulkShellKeys)
            Config.options.appearance.fonts[key] = parts.family;
    }

    function setFamily(role: string, shellKeys: var, family: string): void {
        DesktopAppearance.setFont(role, {
            family: family
        });
        for (const key of shellKeys)
            Config.options.appearance.fonts[key] = family;
    }

    function indexOfValue(model: var, value: var): int {
        const found = model.findIndex(item => item.value === value);
        return found !== -1 ? found : 0;
    }

    Component.onCompleted: DesktopAppearance.loadFamilies()

    ContentSection {
        icon: "palette"
        title: Translation.tr("Theme")

        ContentSubsection {
            title: Translation.tr("GTK theme")

            StyledComboBox {
                buttonIcon: "web_asset"
                textRole: "displayName"
                model: root.named(DesktopAppearance.gtkThemes)
                currentIndex: root.indexOfValue(model, DesktopAppearance.gtkTheme)
                onActivated: index => DesktopAppearance.setThemes(model[index].value, DesktopAppearance.qtStyle)
            }
        }

        ContentSubsection {
            title: Translation.tr("Qt style")

            StyledComboBox {
                buttonIcon: "format_paint"
                textRole: "displayName"
                model: root.named(DesktopAppearance.qtStyles)
                currentIndex: root.indexOfValue(model, DesktopAppearance.qtStyle)
                onActivated: index => DesktopAppearance.setThemes(DesktopAppearance.gtkTheme, model[index].value)
            }
        }

        ContentSubsection {
            title: Translation.tr("Icon theme")
            tooltip: Translation.tr("Applied to GTK, Qt and the shell at once.")

            StyledComboBox {
                buttonIcon: "imagesmode"
                textRole: "displayName"
                model: root.named(DesktopAppearance.iconThemes)
                currentIndex: root.indexOfValue(model, DesktopAppearance.iconTheme)
                onActivated: index => DesktopAppearance.setIcons(model[index].value)
            }
        }
    }

    ContentSection {
        icon: "colors"
        title: Translation.tr("Color generation")

        ContentSubsection {
            title: Translation.tr("What gets themed")

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
        }

        ContentSubsection {
            title: Translation.tr("Terminal colors")
            tooltip: Translation.tr("Ignored if terminal theming is not enabled")

            ConfigSwitch {
                buttonIcon: "dark_mode"
                text: Translation.tr("Force dark mode in terminal")
                checked: Config.options.appearance.wallpaperTheming.terminalGenerationProps.forceDarkMode
                onCheckedChanged: {
                     Config.options.appearance.wallpaperTheming.terminalGenerationProps.forceDarkMode= checked;
                }
            }

            ConfigSpinBox {
                icon: "invert_colors"
                text: Translation.tr("Harmony (%)")
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
                text: Translation.tr("Harmonize threshold")
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
                text: Translation.tr("Foreground boost (%)")
                value: Config.options.appearance.wallpaperTheming.terminalGenerationProps.termFgBoost * 100
                from: 0
                to: 100
                stepSize: 10
                onValueChanged: {
                    Config.options.appearance.wallpaperTheming.terminalGenerationProps.termFgBoost = value / 100;
                }
            }
        }
    }

    ContentSection {
        icon: "text_format"
        title: Translation.tr("Fonts")

        ContentSubsection {
            title: Translation.tr("Apps & panels")
            tooltip: Translation.tr("Sizes apply to GTK and Qt apps; panels scale their own.")

            Repeater {
                model: root.fontRoles

                ConfigRow {
                    id: fontRole

                    required property var modelData

                    readonly property var font: DesktopAppearance.fonts[fontRole.modelData.role] ?? ({
                            family: "",
                            style: "",
                            size: 10
                        })

                    uniform: false

                    ContentSubsectionLabel {
                        Layout.preferredWidth: root.fontLabelWidth
                        text: fontRole.modelData.name
                    }

                    StyledComboBox {
                        Layout.fillWidth: true
                        buttonIcon: "font_download"
                        textRole: "displayName"
                        model: root.familyOptions(fontRole.font.family)
                        currentIndex: root.indexOfValue(model, fontRole.font.family)
                        onActivated: index => root.setFamily(fontRole.modelData.role, fontRole.modelData.shellKeys, model[index].value)
                    }

                    OptionSpinBox {
                        current: fontRole.font.size
                        from: 5
                        to: 72
                        stepSize: 1
                        onCommitted: size => DesktopAppearance.setFont(fontRole.modelData.role, {
                                size: size
                            })
                    }
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Adjust all")
            tooltip: Translation.tr("Sets every role above at once. Fixed width keeps its own family so code stays monospaced.")

            ConfigRow {
                uniform: true

                ConfigSwitch {
                    buttonIcon: "font_download"
                    text: Translation.tr("Family")
                    checked: root.bulkChangesFamily
                    onCheckedChanged: {
                        root.bulkChangesFamily = checked;
                    }
                }

                ConfigSwitch {
                    buttonIcon: "format_size"
                    text: Translation.tr("Size")
                    checked: root.bulkChangesSize
                    onCheckedChanged: {
                        root.bulkChangesSize = checked;
                    }
                }
            }

            ConfigRow {
                uniform: false

                StyledComboBox {
                    Layout.fillWidth: true
                    enabled: root.bulkChangesFamily
                    buttonIcon: "font_download"
                    textRole: "displayName"
                    model: root.familyOptions(root.bulkFamily)
                    currentIndex: root.indexOfValue(model, root.bulkFamily)
                    onActivated: index => {
                        root.bulkFamily = model[index].value;
                    }
                }

                OptionSpinBox {
                    enabled: root.bulkChangesSize
                    current: root.bulkSize
                    from: 5
                    to: 72
                    stepSize: 1
                    onCommitted: size => {
                        root.bulkSize = size;
                    }
                }
            }

            RippleButtonWithIcon {
                materialIcon: "done_all"
                mainText: Translation.tr("Apply to all fonts")
                onClicked: root.adjustAll()
            }
        }

        ContentSubsection {
            title: Translation.tr("Panels only")
            tooltip: Translation.tr("Faces the shell uses that GTK and Qt have no equivalent for")

            Repeater {
                model: root.shellOnlyFontRoles

                ConfigRow {
                    id: shellFont

                    required property var modelData

                    readonly property string family: Config.options.appearance.fonts[shellFont.modelData.key]

                    uniform: false

                    ContentSubsectionLabel {
                        Layout.preferredWidth: root.fontLabelWidth
                        text: shellFont.modelData.name
                    }

                    StyledComboBox {
                        Layout.fillWidth: true
                        buttonIcon: "font_download"
                        textRole: "displayName"
                        model: root.familyOptions(shellFont.family)
                        currentIndex: root.indexOfValue(model, shellFont.family)
                        onActivated: index => {
                            Config.options.appearance.fonts[shellFont.modelData.key] = model[index].value;
                        }
                    }
                }
            }
        }
    }

    ContentSection {
        icon: "mouse"
        title: Translation.tr("Pointer")

        ContentSubsection {
            title: Translation.tr("Cursor theme")
            tooltip: Translation.tr("Applied to Wayland, XWayland, GTK and Qt at once.")

            StyledComboBox {
                buttonIcon: "mouse"
                textRole: "displayName"
                model: root.named(DesktopAppearance.cursorThemes)
                currentIndex: root.indexOfValue(model, DesktopAppearance.cursorTheme)
                onActivated: index => DesktopAppearance.setCursor(model[index].value, DesktopAppearance.cursorSize)
            }
        }

        OptionSpinBox {
            icon: "height"
            text: Translation.tr("Cursor size")
            current: DesktopAppearance.cursorSize
            from: 8
            to: 128
            stepSize: 4
            onCommitted: size => DesktopAppearance.setCursor(DesktopAppearance.cursorTheme, size)
        }
    }

    ContentSection {
        icon: "select_window"
        title: Translation.tr("Windows")

        ContentSubsection {
            title: Translation.tr("Corners")

            OptionSpinBox {
                icon: "rounded_corner"
                text: Translation.tr("Corner rounding")
                current: HyprlandOptions.number("decoration:rounding")
                from: 0
                to: 40
                stepSize: 1
                onCommitted: radius => HyprlandOptions.set("decoration:rounding", radius)
            }

            OptionSpinBox {
                icon: "line_curve"
                text: Translation.tr("Corner shape")
                current: Math.round(HyprlandOptions.number("decoration:rounding_power") * 10)
                decimals: 1
                from: 20
                to: 100
                stepSize: 1
                onCommitted: power => HyprlandOptions.set("decoration:rounding_power", power / 10)
                StyledToolTip {
                    text: Translation.tr("2 is a circle, higher squares the corner off while keeping it smooth")
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Blur")

            ConfigSwitch {
                buttonIcon: "blur_on"
                text: Translation.tr("Blur behind windows")
                checked: HyprlandOptions.flag("decoration:blur:enabled")
                onCheckedChanged: {
                    if (checked !== HyprlandOptions.flag("decoration:blur:enabled"))
                        HyprlandOptions.set("decoration:blur:enabled", checked);
                }
            }

            ConfigRow {
                enabled: HyprlandOptions.flag("decoration:blur:enabled")

                OptionSpinBox {
                    icon: "blur_circular"
                    text: Translation.tr("Radius")
                    current: HyprlandOptions.number("decoration:blur:size")
                    from: 1
                    to: 40
                    stepSize: 1
                    onCommitted: size => HyprlandOptions.set("decoration:blur:size", size)
                }

                OptionSpinBox {
                    icon: "layers"
                    text: Translation.tr("Passes")
                    current: HyprlandOptions.number("decoration:blur:passes")
                    from: 1
                    to: 10
                    stepSize: 1
                    onCommitted: passes => HyprlandOptions.set("decoration:blur:passes", passes)
                }
            }

            ConfigSwitch {
                buttonIcon: "hide_image"
                text: Translation.tr("X-ray")
                enabled: HyprlandOptions.flag("decoration:blur:enabled")
                checked: HyprlandOptions.flag("decoration:blur:xray")
                onCheckedChanged: {
                    if (checked !== HyprlandOptions.flag("decoration:blur:xray"))
                        HyprlandOptions.set("decoration:blur:xray", checked);
                }
                StyledToolTip {
                    text: Translation.tr("A floating window blurs the wallpaper rather than the windows behind it")
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Opacity")

            ConfigRow {
                OptionSpinBox {
                    icon: "opacity"
                    text: Translation.tr("Focused window (%)")
                    current: Math.round(HyprlandOptions.number("decoration:active_opacity") * 100)
                    from: 10
                    to: 100
                    stepSize: 1
                    onCommitted: opacity => HyprlandOptions.set("decoration:active_opacity", opacity / 100)
                }

                OptionSpinBox {
                    icon: "opacity"
                    text: Translation.tr("Other windows (%)")
                    current: Math.round(HyprlandOptions.number("decoration:inactive_opacity") * 100)
                    from: 10
                    to: 100
                    stepSize: 1
                    onCommitted: opacity => HyprlandOptions.set("decoration:inactive_opacity", opacity / 100)
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Rendering")

            ConfigSwitch {
                buttonIcon: "animation"
                text: Translation.tr("Animations")
                checked: HyprlandOptions.flag("animations:enabled")
                onCheckedChanged: {
                    if (checked !== HyprlandOptions.flag("animations:enabled"))
                        HyprlandOptions.set("animations:enabled", checked);
                }
            }

            ConfigSwitch {
                buttonIcon: "screenshot_monitor"
                text: Translation.tr("Allow tearing")
                checked: HyprlandOptions.flag("general:allow_tearing")
                onCheckedChanged: {
                    if (checked !== HyprlandOptions.flag("general:allow_tearing"))
                        HyprlandOptions.set("general:allow_tearing", checked);
                }
                StyledToolTip {
                    text: Translation.tr("Lets a game draw a frame before the display is ready for it, trading a torn line for latency")
                }
            }
        }
    }

    ContentSection {
        icon: "select_window_2"
        title: Translation.tr("Shell windows")

        ConfigSwitch {
            buttonIcon: "toolbar"
            text: Translation.tr("Show title bar")
            checked: Config.options.windows.showTitlebar
            onCheckedChanged: {
                Config.options.windows.showTitlebar = checked;
            }
            StyledToolTip {
                text: Translation.tr("Client-side decorations for shell apps like this one")
            }
        }

        ConfigSwitch {
            buttonIcon: "format_align_center"
            text: Translation.tr("Center title")
            enabled: Config.options.windows.showTitlebar
            checked: Config.options.windows.centerTitle
            onCheckedChanged: {
                Config.options.windows.centerTitle = checked;
            }
        }
    }
}
