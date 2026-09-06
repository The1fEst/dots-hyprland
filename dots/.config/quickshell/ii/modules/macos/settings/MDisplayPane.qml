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

    readonly property list<var> modes: {
        const seen = new Map();
        for (const mode of root.monitor?.availableModes ?? []) {
            const parts = mode.match(/^(\d+)x(\d+)@([\d.]+)Hz$/);
            if (!parts)
                continue;
            const size = `${parts[1]}x${parts[2]}`;
            const rate = parseFloat(parts[3]);
            const known = seen.get(size);
            if (!known)
                seen.set(size, {
                    width: parseInt(parts[1]),
                    height: parseInt(parts[2]),
                    rates: [rate]
                });
            else if (!known.rates.includes(rate))
                known.rates.push(rate);
        }
        return [...seen.values()].sort((a, b) => b.width * b.height - a.width * a.height);
    }

    readonly property var nativeMode: root.modes[0] ?? null

    readonly property real logicalWidth: Math.round((root.monitor?.width ?? 0) / Math.max(0.01, root.monitor?.scale ?? 1))
    readonly property real logicalHeight: Math.round((root.monitor?.height ?? 0) / Math.max(0.01, root.monitor?.scale ?? 1))

    readonly property list<var> scaledModes: {
        const native = root.nativeMode;
        if (!native)
            return [];
        const out = [];
        for (const divisor of [1, 1.25, 4 / 3, 1.5, 1.6, 2]) {
            const width = native.width / divisor;
            const height = native.height / divisor;
            if (Math.abs(width - Math.round(width)) > 0.001 || Math.abs(height - Math.round(height)) > 0.001)
                continue;
            out.push({
                width: Math.round(width),
                height: Math.round(height),
                mode: native,
                scale: Math.round(divisor * 1e6) / 1e6,
                native: divisor === 1
            });
        }
        return out;
    }

    readonly property list<var> panelModes: root.modes.map(mode => ({
                width: mode.width,
                height: mode.height,
                mode: mode,
                scale: 1,
                rate: mode.rates.slice().sort((a, b) => b - a)[0],
                native: mode === root.nativeMode
            }))

    property bool allResolutions: false

    readonly property list<var> shownModes: {
        if (!root.allResolutions)
            return root.scaledModes;
        const out = root.scaledModes.slice();
        const seen = new Set(out.map(entry => `${entry.width}x${entry.height}`));
        for (const entry of root.panelModes) {
            const size = `${entry.width}x${entry.height}`;
            if (seen.has(size))
                continue;
            seen.add(size);
            out.push(entry);
        }
        return out.sort((a, b) => b.width * b.height - a.width * a.height);
    }

    readonly property list<var> ratesForCurrentSize: (root.modes.find(m => m.width === root.monitor?.width && m.height === root.monitor?.height)?.rates ?? []).slice().sort((a, b) => b - a)

    readonly property list<var> colorProfiles: [
        {
            label: qsTr("Automatic"),
            value: "auto"
        },
        {
            label: qsTr("sRGB"),
            value: "srgb"
        },
        {
            label: qsTr("DCI P3"),
            value: "dcip3"
        },
        {
            label: qsTr("Display P3"),
            value: "dp3"
        },
        {
            label: qsTr("Adobe RGB"),
            value: "adobe"
        },
        {
            label: qsTr("Wide color"),
            value: "wide"
        },
        {
            label: root.monitor?.model || qsTr("Display profile"),
            value: "edid"
        },
        {
            label: qsTr("HDR"),
            value: "hdr"
        },
        {
            label: qsTr("HDR (%1)").arg(root.monitor?.model || qsTr("display profile")),
            value: "hdredid"
        }
    ]

    property var persisted: ({})
    property list<string> iccProfiles: []

    readonly property var ruleDefaults: ({
        bitdepth: 8,
        sdr_eotf: "default",
        sdrbrightness: 1,
        sdrsaturation: 1,
        vrr: -1,
        icc: "",
        supports_wide_color: 0,
        supports_hdr: 0,
        sdr_min_luminance: 0.2,
        sdr_max_luminance: 80,
        min_luminance: -1,
        max_luminance: -1,
        max_avg_luminance: -1,
        reserved_area: "0"
    })

    readonly property var rule: root.persisted[root.monitor?.name ?? ""] ?? ({})

    readonly property string colorProfile: root.rule.cm ?? root.monitor?.colorManagementPreset ?? "srgb"

    function ruleValue(key: string): var {
        return root.rule[key] ?? root.ruleDefaults[key];
    }

    function ruleNumber(key: string): real {
        return Number(root.ruleValue(key));
    }

    function reservedSide(side: string): int {
        const area = String(root.ruleValue("reserved_area"));
        const named = area.match(new RegExp(`${side}\\s*=\\s*(-?\\d+)`));
        if (named)
            return parseInt(named[1]);
        return parseInt(area) || 0;
    }

    function setReservedSide(side: string, size: int): void {
        const sides = ["top", "right", "bottom", "left"].map(name => `${name} = ${name === side ? size : root.reservedSide(name)}`);
        root.apply({
            reserved_area: `{ ${sides.join(", ")} }`
        });
    }

    function setColorProfile(profile: string): void {
        root.apply({
            bitdepth: profile.startsWith("hdr") ? 10 : 8,
            cm: profile
        });
    }

    function rateLabel(rate: real): string {
        return qsTr("%1 Hertz").arg(Math.round(rate));
    }

    function ruleForWhatIsRunning(monitor: var, size: string, rate: real): var {
        const kept = root.persisted[monitor.name] ?? ({});
        return {
            mode: `${size}@${rate.toFixed(2)}`,
            position: `${monitor.x}x${monitor.y}`,
            scale: monitor.scale,
            transform: monitor.transform,
            bitdepth: kept.bitdepth ?? (monitor.currentFormat.includes("2101010") ? 10 : 8),
            cm: kept.cm ?? monitor.colorManagementPreset
        };
    }

    function applyTo(monitor: var, keys: var): void {
        if (!monitor)
            return;
        const size = keys.size ?? `${monitor.width}x${monitor.height}`;
        const rate = keys.rate ?? monitor.refreshRate;

        const settings = Object.assign(root.ruleForWhatIsRunning(monitor, size, rate), keys);
        delete settings.size;
        delete settings.rate;

        const pairs = Object.keys(settings).map(key => `${key}=${settings[key]}`);
        persistProc.exec(["python3", Quickshell.shellPath("scripts/system/hypr-monitor.py"), Quickshell.env("HOME") + "/.config/hypr/settings.lua", monitor.name].concat(pairs));
    }

    function apply(keys: var): void {
        root.applyTo(root.monitor, keys);
    }

    function moveTo(name: string, x: int, y: int): void {
        root.applyTo(root.monitors.find(m => m.name === name), {
            position: `${x}x${y}`
        });
    }

    Process {
        id: reloadProc
        command: ["hyprctl", "reload"]
        onExited: {
            HyprlandData.updateMonitors();
            readProc.running = true;
        }
    }

    Process {
        id: persistProc
        onExited: reloadProc.running = true
    }

    Process {
        id: iccProc
        running: true
        command: ["python3", Quickshell.shellPath("scripts/system/hypr-monitor.py"), "--icc-profiles"]

        stdout: StdioCollector {
            onStreamFinished: root.iccProfiles = JSON.parse(this.text.length > 0 ? this.text : "[]")
        }
    }

    Process {
        id: readProc
        running: true
        command: ["python3", Quickshell.shellPath("scripts/system/hypr-monitor.py"), "--read", Quickshell.env("HOME") + "/.config/hypr/settings.lua"]

        stdout: StdioCollector {
            onStreamFinished: root.persisted = JSON.parse(this.text.length > 0 ? this.text : "{}")
        }
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
                current: root.others.find(other => other.name === root.monitor?.mirrorOf)?.name ?? "extend"
                options: [
                    {
                        label: qsTr("Extended display"),
                        value: "extend"
                    }
                ].concat(root.others.map(other => ({
                            label: qsTr("Mirror for %1").arg(other.model || other.name),
                            value: other.name
                        })))
                onSelected: value => root.apply({
                    mirror: value === "extend" ? "" : value
                })
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
                controlHeight: Looks.control.small
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
