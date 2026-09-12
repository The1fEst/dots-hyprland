pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.macos.controls
import qs.modules.macos.looks

Column {
    id: root

    property string selectedOutput: ""

    readonly property list<var> monitors: HyprlandData.monitors
    readonly property var monitor: root.monitors.find(m => m.name === root.selectedOutput) ?? root.monitors[0] ?? null
    readonly property list<var> others: root.monitors.filter(m => m.name !== root.monitor?.name)

    readonly property string wallpaper: Config.options?.background.wallpaperPath ?? ""

    readonly property real logicalWidth: Math.round((root.monitor?.width ?? 0) / Math.max(0.01, root.monitor?.scale ?? 1))
    readonly property real logicalHeight: Math.round((root.monitor?.height ?? 0) / Math.max(0.01, root.monitor?.scale ?? 1))

    property bool allResolutions: false

    readonly property list<var> shownModes: DisplayOptions.shownModesOf(root.monitor, root.allResolutions)
    readonly property list<var> ratesForCurrentSize: DisplayOptions.ratesOf(root.monitor)

    readonly property list<var> colorProfiles: DisplayOptions.colorProfiles(root.monitor)

    readonly property string primary: DisplayOptions.primary
    readonly property list<string> iccProfiles: DisplayOptions.iccProfiles

    readonly property string colorProfile: DisplayOptions.colorProfileOf(root.monitor)

    function ruleValue(key: string): var {
        return DisplayOptions.valueOf(root.monitor?.name ?? "", key);
    }

    function ruleNumber(key: string): real {
        return DisplayOptions.numberOf(root.monitor?.name ?? "", key);
    }

    function reservedSide(side: string): int {
        return DisplayOptions.reservedSideOf(root.monitor?.name ?? "", side);
    }

    function setReservedSide(side: string, size: int): void {
        DisplayOptions.setReservedSide(root.monitor, side, size);
    }

    function setColorProfile(profile: string): void {
        DisplayOptions.setColorProfile(root.monitor, profile);
    }

    function rateLabel(rate: real): string {
        return qsTr("%1 Hertz").arg(Math.round(rate));
    }

    function apply(keys: var): void {
        DisplayOptions.applyTo(root.monitor, keys);
    }

    function useAs(value: string): void {
        if (value === "main") {
            DisplayOptions.setPrimary(root.monitor?.name ?? "", null);
            return;
        }
        const keys = {
            mirror: value === "extend" ? "" : value
        };
        if (root.primary === root.monitor?.name)
            DisplayOptions.setPrimary(root.others[0]?.name ?? "", keys);
        else
            root.apply(keys);
    }

    function moveTo(name: string, x: int, y: int): void {
        DisplayOptions.moveTo(name, x, y);
    }

    spacing: Looks.settings.formGap

    readonly property int headerHeight: 158
    readonly property int headerTopGap: 51
    readonly property int bandHeight: Looks.metrics.titlebar.height + root.headerHeight
    readonly property real notchCentre: header.notchCentre
    readonly property int notchTail: 9

    readonly property int thumbWidth: 116
    readonly property int thumbBezel: 3
    readonly property int pickerSpacing: 24
    readonly property int pickerLabelGap: 8

    Item {
        id: header

        readonly property int selectedIndex: Math.max(0, root.monitors.findIndex(m => m.name === root.monitor?.name))
        readonly property real notchCentre: picker.x + header.selectedIndex * (root.thumbWidth + root.pickerSpacing) + root.thumbWidth / 2

        x: -Looks.settings.formInset
        width: parent.width + Looks.settings.formInset * 2
        height: root.headerHeight - Looks.settings.paneTopGap
        y: -Looks.settings.paneTopGap

        Row {
            id: picker
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: root.headerTopGap - Looks.settings.paneTopGap
            }
            spacing: root.pickerSpacing

            Repeater {
                model: root.monitors

                Column {
                    id: pick

                    required property var modelData

                    readonly property bool current: pick.modelData.name === root.monitor?.name

                    width: root.thumbWidth
                    spacing: root.pickerLabelGap

                    MDisplayThumb {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: root.thumbWidth
                        height: Math.round(width * pick.modelData.height / Math.max(1, pick.modelData.width))
                    }

                    MText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: pick.modelData.model || pick.modelData.name
                        emphasized: pick.current
                    }

                    TapHandler {
                        onTapped: root.selectedOutput = pick.modelData.name
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }

    MSettingsGroup {
        width: parent.width

        MSettingsRow {
            label: qsTr("Use as")
            visible: root.others.length > 0

            MPopupButton {
                current: root.primary === root.monitor?.name ? "main" : (root.others.find(other => other.name === root.monitor?.mirrorOf)?.name ?? "extend")
                options: [
                    {
                        label: qsTr("Main display"),
                        value: "main"
                    },
                    {
                        label: qsTr("Extended display"),
                        value: "extend"
                    }
                ].concat(root.others.map(other => ({
                            label: qsTr("Mirror for %1").arg(other.model || other.name),
                            value: other.name
                        })))
                onSelected: value => root.useAs(value)
            }
        }


        Repeater {
            model: root.shownModes

            MTableRow {
                required property var modelData
                required property int index

                label: modelData.native ? qsTr("%1 × %2 (Default)").arg(modelData.width).arg(modelData.height) : `${modelData.width} × ${modelData.height}`
                selected: modelData.width === root.logicalWidth && modelData.height === root.logicalHeight
                separator: index < root.shownModes.length - 1
                onClicked: root.apply({
                    size: `${modelData.mode.width}x${modelData.mode.height}`,
                    rate: modelData.rate,
                    scale: modelData.scale
                })
            }
        }

        MSettingsRow {
            label: qsTr("Show all resolutions")

            MSwitch {
                checked: root.allResolutions
                onToggled: on => root.allResolutions = on
            }
        }

        MSettingsRow {
            separator: false
            note: qsTr("Using a scaled resolution may affect performance.")
        }
    }

    MSettingsGroup {
        width: parent.width

        MSettingsRow {
            label: qsTr("Refresh rate")

            MPopupButton {
                current: root.rateLabel(root.monitor?.refreshRate ?? 0)
                options: root.ratesForCurrentSize.map(rate => ({
                            label: root.rateLabel(rate),
                            value: root.rateLabel(rate)
                        }))
                onSelected: value => root.apply({
                    rate: root.ratesForCurrentSize.find(rate => root.rateLabel(rate) === value)
                })
            }
        }

        MSettingsRow {
            label: qsTr("Variable refresh rate")
            separator: false

            MPopupButton {
                current: String(root.ruleNumber("vrr"))
                options: [
                    {
                        label: qsTr("Follow the global setting"),
                        value: "-1"
                    },
                    {
                        label: qsTr("Off"),
                        value: "0"
                    },
                    {
                        label: qsTr("On"),
                        value: "1"
                    },
                    {
                        label: qsTr("Fullscreen only"),
                        value: "2"
                    },
                    {
                        label: qsTr("Fullscreen games and video"),
                        value: "3"
                    }
                ]
                onSelected: value => root.apply({
                    vrr: parseInt(value)
                })
            }
        }
    }

    MPushButton {
        anchors.right: parent.right
        visible: root.monitors.length > 1
        label: qsTr("Arrange…")
        onClicked: arrange.open()
    }

    MDisplayColour {
        width: parent.width
        pane: root
    }

    MDisplayLuminance {
        width: parent.width
        pane: root
    }

    MSettingsGroup {
        width: parent.width

        MSettingsRow {
            label: qsTr("Rotation")
            separator: false

            MPopupButton {
                current: String(root.monitor?.transform ?? 0)
                options: [
                    {
                        label: qsTr("Standard"),
                        value: "0"
                    },
                    {
                        label: qsTr("90°"),
                        value: "1"
                    },
                    {
                        label: qsTr("180°"),
                        value: "2"
                    },
                    {
                        label: qsTr("270°"),
                        value: "3"
                    },
                    {
                        label: qsTr("Flipped"),
                        value: "4"
                    },
                    {
                        label: qsTr("Flipped, 90°"),
                        value: "5"
                    },
                    {
                        label: qsTr("Flipped, 180°"),
                        value: "6"
                    },
                    {
                        label: qsTr("Flipped, 270°"),
                        value: "7"
                    }
                ]
                onSelected: value => root.apply({
                    transform: parseInt(value)
                })
            }
        }
    }

    MSettingsGroup {
        width: parent.width
        title: qsTr("Reserved area")

        Repeater {
            model: ["top", "right", "bottom", "left"]

            MSettingsRow {
                id: side

                required property string modelData

                readonly property var names: ({
                    top: qsTr("Top"),
                    right: qsTr("Right"),
                    bottom: qsTr("Bottom"),
                    left: qsTr("Left")
                })

                label: side.names[side.modelData]

                MNumberField {
                    from: 0
                    to: 2000
                    fieldWidth: 44
                    value: root.reservedSide(side.modelData)
                    onEdited: size => root.setReservedSide(side.modelData, size)
                }
            }
        }

        MSettingsRow {
            separator: false
            note: qsTr("Space kept clear of tiled windows along each edge of this display.")
        }
    }

    MArrangeSheet {
        id: arrange
        monitors: root.monitors
        wallpaper: root.wallpaper
        onMoved: (name, x, y) => root.moveTo(name, x, y)
    }

    component MDisplayThumb: ClippingRectangle {
        id: thumb

        radius: Looks.radius.tiny
        antialiasing: true
        color: "#0c0c0c"

        StyledImage {
            anchors.fill: parent
            anchors.margins: root.thumbBezel
            source: root.wallpaper.length > 0 ? "file://" + root.wallpaper : ""
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(thumb.width * 2, thumb.height * 2)
        }
    }

}
