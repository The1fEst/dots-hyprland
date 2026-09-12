pragma ComponentBehavior: Bound

import QtQuick
import qs.services
import qs.modules.common
import qs.modules.macos.controls
import qs.modules.macos.looks

Column {
    id: root

    readonly property var dock: Config.options?.dock ?? null
    readonly property var sizes: Config.options?.macos.dock ?? null

    readonly property int minimumIcon: 32
    readonly property int maximumIcon: 96
    readonly property int maximumMagnification: 48

    spacing: Looks.settings.formGap

    function fraction(value: real, low: real, high: real): real {
        return Math.max(0, Math.min(1, (value - low) / (high - low)));
    }

    MSettingsGroup {
        width: parent.width
        title: qsTr("Dock")

        MSettingsRow {
            label: qsTr("Size")

            MSlider {
                value: root.fraction(root.sizes?.iconSize ?? 57, root.minimumIcon, root.maximumIcon)
                onMoved: part => root.sizes.iconSize = Math.round(root.minimumIcon + part * (root.maximumIcon - root.minimumIcon))
            }
        }

        MSettingsRow {
            label: qsTr("Magnification")
            detail: qsTr("How far an icon grows when the pointer is over it.")
            wrapDetail: true
            separator: false

            MSlider {
                value: root.fraction(root.sizes?.magnification ?? 27, 0, root.maximumMagnification)
                onMoved: part => root.sizes.magnification = Math.round(part * root.maximumMagnification)
            }
        }
    }

    MSettingsGroup {
        width: parent.width

        MSettingsRow {
            label: qsTr("Automatically hide and show the Dock")
            wrapLabel: true

            MSwitch {
                checked: !(root.dock?.pinnedOnStartup ?? false)
                onToggled: on => root.dock.pinnedOnStartup = !on
            }
        }

        MSettingsRow {
            label: qsTr("Reveal on hover")
            detail: qsTr("Off reveals the Dock only on a workspace with no windows.")
            wrapDetail: true

            MSwitch {
                checked: root.dock?.hoverToReveal ?? false
                onToggled: on => root.dock.hoverToReveal = on
            }
        }

        MSettingsRow {
            label: qsTr("Hover region height")

            MNumberField {
                from: 1
                to: 40
                value: root.dock?.hoverRegionHeight ?? 2
                onEdited: height => root.dock.hoverRegionHeight = height
            }
        }

        MSettingsRow {
            label: qsTr("Show indicators for open applications")
            wrapLabel: true
            separator: false

            MSwitch {
                checked: root.sizes?.showIndicators ?? true
                onToggled: on => root.sizes.showIndicators = on
            }
        }
    }

    MSettingsGroup {
        width: parent.width
        title: qsTr("Windows")

        MSettingsRow {
            label: qsTr("Gap between windows")

            MNumberField {
                from: 0
                to: 100
                value: WindowOptions.number("general:gaps_in")
                onEdited: gap => WindowOptions.set("general:gaps_in", gap)
            }
        }

        MSettingsRow {
            label: qsTr("Gap around the screen")

            MNumberField {
                from: 0
                to: 200
                value: WindowOptions.number("general:gaps_out")
                onEdited: gap => WindowOptions.set("general:gaps_out", gap)
            }
        }

        MSettingsRow {
            label: qsTr("Border width")

            MNumberField {
                from: 0
                to: 20
                value: WindowOptions.number("general:border_size")
                onEdited: width => WindowOptions.set("general:border_size", width)
            }
        }

        MSettingsRow {
            label: qsTr("Corner rounding")

            MNumberField {
                from: 0
                to: 40
                value: WindowOptions.number("decoration:rounding")
                onEdited: radius => WindowOptions.set("decoration:rounding", radius)
            }
        }

        MSettingsRow {
            label: qsTr("Corner shape")
            detail: qsTr("2 is a circle, higher squares the corner off while keeping it smooth.")
            wrapDetail: true

            MNumberField {
                from: 2
                to: 10
                step: 0.1
                decimals: 1
                fieldWidth: 44
                value: WindowOptions.number("decoration:rounding_power")
                onEdited: power => WindowOptions.set("decoration:rounding_power", power)
            }
        }

        MSettingsRow {
            label: qsTr("Blur behind windows")

            MSwitch {
                checked: WindowOptions.flag("decoration:blur:enabled")
                onToggled: on => WindowOptions.set("decoration:blur:enabled", on)
            }
        }

        MSettingsRow {
            label: qsTr("Blur radius")

            MNumberField {
                available: WindowOptions.flag("decoration:blur:enabled")
                from: 1
                to: 40
                value: WindowOptions.number("decoration:blur:size")
                onEdited: size => WindowOptions.set("decoration:blur:size", size)
            }
        }

        MSettingsRow {
            label: qsTr("Blur passes")

            MNumberField {
                available: WindowOptions.flag("decoration:blur:enabled")
                from: 1
                to: 10
                value: WindowOptions.number("decoration:blur:passes")
                onEdited: passes => WindowOptions.set("decoration:blur:passes", passes)
            }
        }

        MSettingsRow {
            label: qsTr("Blur x-ray")
            detail: qsTr("A floating window blurs the wallpaper rather than the windows behind it.")
            wrapDetail: true

            MSwitch {
                available: WindowOptions.flag("decoration:blur:enabled")
                checked: WindowOptions.flag("decoration:blur:xray")
                onToggled: on => WindowOptions.set("decoration:blur:xray", on)
            }
        }

        MSettingsRow {
            label: qsTr("Opacity of the focused window")
            wrapLabel: true

            MNumberField {
                from: 0.1
                to: 1
                step: 0.01
                decimals: 2
                fieldWidth: 48
                value: WindowOptions.number("decoration:active_opacity")
                onEdited: opacity => WindowOptions.set("decoration:active_opacity", opacity)
            }
        }

        MSettingsRow {
            label: qsTr("Opacity of the other windows")
            wrapLabel: true

            MNumberField {
                from: 0.1
                to: 1
                step: 0.01
                decimals: 2
                fieldWidth: 48
                value: WindowOptions.number("decoration:inactive_opacity")
                onEdited: opacity => WindowOptions.set("decoration:inactive_opacity", opacity)
            }
        }

        MSettingsRow {
            label: qsTr("Animations")

            MSwitch {
                checked: WindowOptions.flag("animations:enabled")
                onToggled: on => WindowOptions.set("animations:enabled", on)
            }
        }

        MSettingsRow {
            label: qsTr("Allow tearing")
            detail: qsTr("Lets a game draw a frame before the display is ready for it, trading a torn line for latency.")
            wrapDetail: true
            separator: false

            MSwitch {
                checked: WindowOptions.flag("general:allow_tearing")
                onToggled: on => WindowOptions.set("general:allow_tearing", on)
            }
        }
    }
}
