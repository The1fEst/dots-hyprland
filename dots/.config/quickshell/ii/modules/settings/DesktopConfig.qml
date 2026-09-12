import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    readonly property list<var> fontRoles: [
        {
            role: "general",
            name: Translation.tr("General")
        },
        {
            role: "fixed",
            name: Translation.tr("Fixed width")
        },
        {
            role: "small",
            name: Translation.tr("Small")
        },
        {
            role: "toolbar",
            name: Translation.tr("Toolbar")
        },
        {
            role: "menu",
            name: Translation.tr("Menu")
        },
        {
            role: "title",
            name: Translation.tr("Window title")
        }
    ]

    function named(values: var): var {
        return values.map(value => ({
                    displayName: value,
                    value: value
                }));
    }

    function indexOfValue(model: var, value: var): int {
        const found = model.findIndex(item => item.value === value);
        return found !== -1 ? found : 0;
    }

    Component.onCompleted: DesktopAppearance.loadFamilies()

    component OptionSpinBox: ConfigSpinBox {
        id: spin

        required property real current

        signal committed(real value)

        onValueChanged: {
            if (value !== spin.current)
                spin.committed(value);
        }

        Binding {
            target: spin
            property: "value"
            value: spin.current
        }
    }

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
        icon: "text_fields"
        title: Translation.tr("Fonts")

        Repeater {
            model: root.fontRoles

            ContentSubsection {
                id: fontRole

                required property var modelData

                readonly property var font: DesktopAppearance.fonts[fontRole.modelData.role] ?? ({
                        family: "",
                        style: "",
                        size: 10
                    })

                title: fontRole.modelData.name

                ConfigRow {
                    uniform: false

                    StyledComboBox {
                        buttonIcon: "font_download"
                        textRole: "displayName"
                        model: root.named(DesktopAppearance.familyNames)
                        currentIndex: root.indexOfValue(model, fontRole.font.family)
                        onActivated: index => DesktopAppearance.setFont(fontRole.modelData.role, {
                                family: model[index].value
                            })
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
    }

    ContentSection {
        icon: "select_window"
        title: Translation.tr("Windows")

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
                },
                {
                    option: "decoration:rounding",
                    icon: "rounded_corner",
                    name: Translation.tr("Corner rounding"),
                    to: 40
                }
            ]

            OptionSpinBox {
                id: windowOption

                required property var modelData

                icon: windowOption.modelData.icon
                text: windowOption.modelData.name
                current: WindowOptions.number(windowOption.modelData.option)
                from: 0
                to: windowOption.modelData.to
                stepSize: 1
                onCommitted: value => WindowOptions.set(windowOption.modelData.option, value)
            }
        }

        OptionSpinBox {
            icon: "line_curve"
            text: Translation.tr("Corner shape")
            current: Math.round(WindowOptions.number("decoration:rounding_power") * 10)
            decimals: 1
            from: 20
            to: 100
            stepSize: 1
            onCommitted: power => WindowOptions.set("decoration:rounding_power", power / 10)
            StyledToolTip {
                text: Translation.tr("2 is a circle, higher squares the corner off while keeping it smooth")
            }
        }

        ConfigSwitch {
            buttonIcon: "blur_on"
            text: Translation.tr("Blur behind windows")
            checked: WindowOptions.flag("decoration:blur:enabled")
            onCheckedChanged: {
                if (checked !== WindowOptions.flag("decoration:blur:enabled"))
                    WindowOptions.set("decoration:blur:enabled", checked);
            }
        }

        ConfigRow {
            enabled: WindowOptions.flag("decoration:blur:enabled")

            OptionSpinBox {
                icon: "blur_circular"
                text: Translation.tr("Blur radius")
                current: WindowOptions.number("decoration:blur:size")
                from: 1
                to: 40
                stepSize: 1
                onCommitted: size => WindowOptions.set("decoration:blur:size", size)
            }

            OptionSpinBox {
                icon: "layers"
                text: Translation.tr("Blur passes")
                current: WindowOptions.number("decoration:blur:passes")
                from: 1
                to: 10
                stepSize: 1
                onCommitted: passes => WindowOptions.set("decoration:blur:passes", passes)
            }
        }

        ConfigSwitch {
            buttonIcon: "hide_image"
            text: Translation.tr("Blur x-ray")
            enabled: WindowOptions.flag("decoration:blur:enabled")
            checked: WindowOptions.flag("decoration:blur:xray")
            onCheckedChanged: {
                if (checked !== WindowOptions.flag("decoration:blur:xray"))
                    WindowOptions.set("decoration:blur:xray", checked);
            }
            StyledToolTip {
                text: Translation.tr("A floating window blurs the wallpaper rather than the windows behind it")
            }
        }

        OptionSpinBox {
            icon: "opacity"
            text: Translation.tr("Opacity of the focused window (%)")
            current: Math.round(WindowOptions.number("decoration:active_opacity") * 100)
            from: 10
            to: 100
            stepSize: 1
            onCommitted: opacity => WindowOptions.set("decoration:active_opacity", opacity / 100)
        }

        OptionSpinBox {
            icon: "opacity"
            text: Translation.tr("Opacity of the other windows (%)")
            current: Math.round(WindowOptions.number("decoration:inactive_opacity") * 100)
            from: 10
            to: 100
            stepSize: 1
            onCommitted: opacity => WindowOptions.set("decoration:inactive_opacity", opacity / 100)
        }

        ConfigSwitch {
            buttonIcon: "animation"
            text: Translation.tr("Animations")
            checked: WindowOptions.flag("animations:enabled")
            onCheckedChanged: {
                if (checked !== WindowOptions.flag("animations:enabled"))
                    WindowOptions.set("animations:enabled", checked);
            }
        }

        ConfigSwitch {
            buttonIcon: "screenshot_monitor"
            text: Translation.tr("Allow tearing")
            checked: WindowOptions.flag("general:allow_tearing")
            onCheckedChanged: {
                if (checked !== WindowOptions.flag("general:allow_tearing"))
                    WindowOptions.set("general:allow_tearing", checked);
            }
            StyledToolTip {
                text: Translation.tr("Lets a game draw a frame before the display is ready for it, trading a torn line for latency")
            }
        }
    }
}
