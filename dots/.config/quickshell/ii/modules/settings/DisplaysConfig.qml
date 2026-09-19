import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    property string selectedOutput: ""
    property bool allResolutions: false

    readonly property list<var> monitors: HyprlandData.monitors
    readonly property var monitor: root.monitors.find(m => m.name === root.selectedOutput) ?? root.monitors[0] ?? null
    readonly property list<var> others: root.monitors.filter(m => m.name !== root.monitor?.name)

    readonly property string name: root.monitor?.name ?? ""

    readonly property real logicalWidth: Math.round((root.monitor?.width ?? 0) / Math.max(0.01, root.monitor?.scale ?? 1))
    readonly property real logicalHeight: Math.round((root.monitor?.height ?? 0) / Math.max(0.01, root.monitor?.scale ?? 1))

    readonly property list<var> forced: [
        {
            displayName: Translation.tr("Automatic"),
            value: 0
        },
        {
            displayName: Translation.tr("On"),
            value: 1
        },
        {
            displayName: Translation.tr("Off"),
            value: -1
        }
    ]

    function indexOfValue(model: var, value: var): int {
        const found = model.findIndex(item => item.value === value);
        return found !== -1 ? found : 0;
    }

    function apply(keys: var): void {
        DisplayOptions.applyTo(root.monitor, keys);
    }

    component RuleSpinBox: OptionSpinBox {
        required property string key

        property real factor: 1

        current: Math.round(DisplayOptions.numberOf(root.name, key) * factor)
        onCommitted: value => root.apply({
                [key]: value / factor
            })
    }

    ContentSection {
        visible: root.monitors.length > 1

        MonitorArrangement {
            Layout.fillWidth: true
            selected: root.name
            onPicked: name => root.selectedOutput = name
            onMoved: (name, x, y) => DisplayOptions.moveTo(name, x, y)
        }
    }

    ContentSection {
        ConfigSelectionArray {
            currentValue: root.name
            onSelected: newValue => root.selectedOutput = newValue
            options: root.monitors.map(monitor => ({
                        value: monitor.name,
                        displayName: `${monitor.model || monitor.name} (${monitor.name})`
                    }))
        }

        RippleButtonWithIcon {
            materialIcon: "refresh"
            mainText: Translation.tr("Rescan displays")
            onClicked: {
                Quickshell.execDetached(["hyprctl", "dispatch", "forcerendererreload"]);
                DisplayOptions.reload();
            }
            StyledToolTip {
                text: Translation.tr("Asks every monitor what it can do again. Modes a display only reports after it is fully awake show up after this.")
            }
        }

        ContentSubsection {
            title: Translation.tr("Use as")
            visible: root.others.length > 0

            StyledComboBox {
                buttonIcon: "desktop_windows"
                textRole: "displayName"
                model: [
                    {
                        displayName: Translation.tr("Main display"),
                        value: "main"
                    },
                    {
                        displayName: Translation.tr("Extended display"),
                        value: "extend"
                    },
                    ...root.others.map(other => ({
                            displayName: Translation.tr("Mirror for %1").arg(other.model || other.name),
                            value: other.name
                        }))
                ]
                boundIndex: {
                    const current = DisplayOptions.primary === root.name ? "main" : (root.others.find(other => other.name === root.monitor?.mirrorOf)?.name ?? "extend");
                    return root.indexOfValue(model, current);
                }
                onActivated: index => {
                    const value = model[index].value;
                    if (value === "main") {
                        DisplayOptions.setPrimary(root.name);
                        return;
                    }
                    if (DisplayOptions.primary === root.name)
                        DisplayOptions.setPrimary(root.others[0]?.name ?? "");
                    root.apply({
                        mirror: value === "extend" ? "" : value
                    });
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Resolution")

            StyledComboBox {
                buttonIcon: "aspect_ratio"
                textRole: "displayName"
                model: DisplayOptions.shownModesOf(root.monitor, root.allResolutions).map(mode => ({
                            displayName: mode.native ? Translation.tr("%1 × %2 (Default)").arg(mode.width).arg(mode.height) : `${mode.width} × ${mode.height}`,
                            value: `${mode.width}x${mode.height}`,
                            mode: mode
                        }))
                boundIndex: root.indexOfValue(model, `${root.logicalWidth}x${root.logicalHeight}`)
                onActivated: index => {
                    const mode = model[index].mode;
                    root.apply({
                        size: `${mode.mode.width}x${mode.mode.height}`,
                        scale: mode.scale,
                        rate: mode.rate ?? root.monitor?.refreshRate
                    });
                }
            }
        }

        ConfigSwitch {
            buttonIcon: "list"
            text: Translation.tr("Show all resolutions")
            checked: root.allResolutions
            onCheckedChanged: root.allResolutions = checked
        }

        ContentSubsection {
            title: Translation.tr("Refresh rate")

            StyledComboBox {
                buttonIcon: "refresh"
                textRole: "displayName"
                model: DisplayOptions.ratesOf(root.monitor).map(rate => ({
                            displayName: Translation.tr("%1 Hz").arg(Math.round(rate)),
                            value: Math.round(rate)
                        }))
                boundIndex: root.indexOfValue(model, Math.round(root.monitor?.refreshRate ?? 0))
                onActivated: index => root.apply({
                        rate: model[index].value
                    })
            }
        }

        ContentSubsection {
            title: Translation.tr("Rotation")

            StyledComboBox {
                buttonIcon: "screen_rotation"
                textRole: "displayName"
                model: [
                    {
                        displayName: Translation.tr("Standard"),
                        value: 0
                    },
                    {
                        displayName: Translation.tr("90°"),
                        value: 1
                    },
                    {
                        displayName: Translation.tr("180°"),
                        value: 2
                    },
                    {
                        displayName: Translation.tr("270°"),
                        value: 3
                    },
                    {
                        displayName: Translation.tr("Flipped"),
                        value: 4
                    },
                    {
                        displayName: Translation.tr("Flipped, 90°"),
                        value: 5
                    },
                    {
                        displayName: Translation.tr("Flipped, 180°"),
                        value: 6
                    },
                    {
                        displayName: Translation.tr("Flipped, 270°"),
                        value: 7
                    }
                ]
                boundIndex: root.indexOfValue(model, root.monitor?.transform ?? 0)
                onActivated: index => root.apply({
                        transform: model[index].value
                    })
            }
        }

        ContentSubsection {
            title: Translation.tr("Variable refresh rate")

            StyledComboBox {
                buttonIcon: "sync"
                textRole: "displayName"
                model: [
                    {
                        displayName: Translation.tr("Follow the global setting"),
                        value: -1
                    },
                    {
                        displayName: Translation.tr("Off"),
                        value: 0
                    },
                    {
                        displayName: Translation.tr("On"),
                        value: 1
                    },
                    {
                        displayName: Translation.tr("Fullscreen only"),
                        value: 2
                    },
                    {
                        displayName: Translation.tr("Fullscreen games and video"),
                        value: 3
                    }
                ]
                boundIndex: root.indexOfValue(model, DisplayOptions.numberOf(root.name, "vrr"))
                onActivated: index => root.apply({
                        vrr: model[index].value
                    })
            }
        }
    }

    ContentSection {
        icon: "palette"
        title: Translation.tr("Color")

        ContentSubsection {
            title: Translation.tr("Color profile")

            StyledComboBox {
                buttonIcon: "colors"
                textRole: "displayName"
                model: DisplayOptions.colorProfiles(root.monitor).map(profile => ({
                            displayName: profile.label,
                            value: profile.value
                        }))
                boundIndex: root.indexOfValue(model, DisplayOptions.colorProfileOf(root.monitor))
                onActivated: index => DisplayOptions.setColorProfile(root.monitor, model[index].value)
            }
        }

        ContentSubsection {
            title: Translation.tr("Bit depth")

            StyledComboBox {
                buttonIcon: "gradient"
                textRole: "displayName"
                model: [
                    {
                        displayName: Translation.tr("8-bit"),
                        value: 8
                    },
                    {
                        displayName: Translation.tr("10-bit"),
                        value: 10
                    }
                ]
                boundIndex: root.indexOfValue(model, DisplayOptions.numberOf(root.name, "bitdepth"))
                onActivated: index => root.apply({
                        bitdepth: model[index].value
                    })
            }
        }

        ContentSubsection {
            title: Translation.tr("Force wide color")

            StyledComboBox {
                buttonIcon: "invert_colors"
                textRole: "displayName"
                model: root.forced
                boundIndex: root.indexOfValue(model, DisplayOptions.numberOf(root.name, "supports_wide_color"))
                onActivated: index => root.apply({
                        supports_wide_color: model[index].value
                    })
            }
        }

        ContentSubsection {
            title: Translation.tr("Force HDR")
            tooltip: Translation.tr("Forcing this on a display that does not report HDR can leave the screen black.")

            StyledComboBox {
                buttonIcon: "hdr_on"
                textRole: "displayName"
                model: root.forced
                boundIndex: root.indexOfValue(model, DisplayOptions.numberOf(root.name, "supports_hdr"))
                onActivated: index => root.apply({
                        supports_hdr: model[index].value
                    })
            }
        }

        ContentSubsection {
            title: Translation.tr("SDR transfer function")

            StyledComboBox {
                buttonIcon: "functions"
                textRole: "displayName"
                model: [
                    {
                        displayName: Translation.tr("Default"),
                        value: "default"
                    },
                    {
                        displayName: Translation.tr("Automatic"),
                        value: "auto"
                    },
                    {
                        displayName: Translation.tr("sRGB"),
                        value: "srgb"
                    },
                    {
                        displayName: Translation.tr("Gamma 2.2"),
                        value: "gamma22"
                    },
                    {
                        displayName: Translation.tr("Gamma 2.2, forced"),
                        value: "gamma22force"
                    }
                ]
                boundIndex: root.indexOfValue(model, DisplayOptions.valueOf(root.name, "sdr_eotf"))
                onActivated: index => root.apply({
                        sdr_eotf: model[index].value
                    })
            }
        }

        ContentSubsection {
            title: Translation.tr("ICC profile")

            StyledComboBox {
                buttonIcon: "description"
                textRole: "displayName"
                model: [
                    {
                        displayName: Translation.tr("None"),
                        value: ""
                    },
                    ...DisplayOptions.iccProfiles.map(path => ({
                            displayName: path.slice(path.lastIndexOf("/") + 1),
                            value: path
                        }))
                ]
                boundIndex: root.indexOfValue(model, DisplayOptions.valueOf(root.name, "icc"))
                onActivated: index => root.apply({
                        icc: model[index].value
                    })
            }
        }
    }

    ContentSection {
        icon: "brightness_6"
        title: Translation.tr("Luminance")

        RuleSpinBox {
            key: "sdrbrightness"
            icon: "brightness_medium"
            text: Translation.tr("SDR brightness")
            factor: 100
            decimals: 2
            from: 0
            to: 1000
            stepSize: 5
            StyledToolTip {
                text: Translation.tr("How bright content that is not HDR is drawn while the display is in HDR")
            }
        }

        RuleSpinBox {
            key: "sdrsaturation"
            icon: "invert_colors"
            text: Translation.tr("SDR saturation")
            factor: 100
            decimals: 2
            from: 0
            to: 1000
            stepSize: 5
        }

        RuleSpinBox {
            key: "sdr_min_luminance"
            icon: "brightness_low"
            text: Translation.tr("SDR minimum luminance")
            factor: 100
            decimals: 2
            from: 0
            to: 100000
            stepSize: 10
        }

        RuleSpinBox {
            key: "sdr_max_luminance"
            icon: "brightness_high"
            text: Translation.tr("SDR maximum luminance")
            from: 0
            to: 10000
            stepSize: 10
        }

        ContentSubsection {
            title: Translation.tr("Display")
            tooltip: Translation.tr("A luminance of −1 leaves the figure to what the display reports.")

            RuleSpinBox {
                key: "min_luminance"
                icon: "nightlight"
                text: Translation.tr("Display minimum luminance")
                factor: 100
                decimals: 2
                from: -100
                to: 100000
                stepSize: 10
            }

            RuleSpinBox {
                key: "max_luminance"
                icon: "wb_sunny"
                text: Translation.tr("Display maximum luminance")
                from: -1
                to: 10000
                stepSize: 10
            }

            RuleSpinBox {
                key: "max_avg_luminance"
                icon: "exposure"
                text: Translation.tr("Display maximum average luminance")
                from: -1
                to: 10000
                stepSize: 10
            }
        }
    }

    ContentSection {
        icon: "border_outer"
        title: Translation.tr("Reserved area")

        Repeater {
            model: [
                {
                    side: "top",
                    icon: "vertical_align_top",
                    name: Translation.tr("Top")
                },
                {
                    side: "right",
                    icon: "align_horizontal_right",
                    name: Translation.tr("Right")
                },
                {
                    side: "bottom",
                    icon: "vertical_align_bottom",
                    name: Translation.tr("Bottom")
                },
                {
                    side: "left",
                    icon: "align_horizontal_left",
                    name: Translation.tr("Left")
                }
            ]

            OptionSpinBox {
                id: reserved

                required property var modelData

                icon: reserved.modelData.icon
                text: reserved.modelData.name
                current: DisplayOptions.reservedSideOf(root.name, reserved.modelData.side)
                from: 0
                to: 2000
                stepSize: 1
                onCommitted: size => DisplayOptions.setReservedSide(root.monitor, reserved.modelData.side, size)
            }
        }
    }

    ContentSection {
        icon: "nightlight"
        title: Translation.tr("Night light")

        ConfigSwitch {
            buttonIcon: "schedule"
            text: Translation.tr("Automatic schedule")
            checked: Config.options.light.night.automatic
            onCheckedChanged: {
                Config.options.light.night.automatic = checked;
            }
        }

        ConfigRow {
            uniform: true
            enabled: Config.options.light.night.automatic
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("From (HH:mm)")
                text: Config.options.light.night.from
                onEditingFinished: {
                    Config.options.light.night.from = text.trim();
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("To (HH:mm)")
                text: Config.options.light.night.to
                onEditingFinished: {
                    Config.options.light.night.to = text.trim();
                }
            }
        }

        ConfigSpinBox {
            icon: "thermostat"
            text: Translation.tr("Color temperature (K)")
            value: Config.options.light.night.colorTemperature
            from: 1000
            to: 6500
            stepSize: 100
            onValueChanged: {
                Config.options.light.night.colorTemperature = value;
            }
        }
    }

}
