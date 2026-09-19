pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root

    readonly property string tool: Quickshell.shellPath("scripts/system/hypr-monitor.py")
    readonly property string file: Quickshell.env("HOME") + "/.config/hypr/settings.lua"

    property var requested: ({})
    property string chosenPrimary: ""
    property list<string> iccProfiles: []

    readonly property var connectorPreference: ({
        DP: 0,
        HDMI: 1,
        DVI: 2,
        eDP: 3,
        LVDS: 4,
        VGA: 5
    })

    readonly property string defaultPrimary: HyprlandData.monitors.slice().sort((a, b) => root.connectorRankOf(a.name) - root.connectorRankOf(b.name) || root.connectorNumberOf(a.name) - root.connectorNumberOf(b.name) || a.name.localeCompare(b.name))[0]?.name ?? ""

    readonly property string primary: HyprlandData.monitors.some(m => m.name === root.chosenPrimary) ? root.chosenPrimary : root.defaultPrimary

    function connectorRankOf(name: string): int {
        const rank = root.connectorPreference[name.split("-")[0]];
        return rank === undefined ? 9 : rank;
    }

    function connectorNumberOf(name: string): int {
        const trailing = name.match(/(\d+)$/);
        return trailing ? parseInt(trailing[1]) : 0;
    }

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

    function colorProfiles(monitor: var): list<var> {
        return [
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
                label: monitor?.model || qsTr("Display profile"),
                value: "edid"
            },
            {
                label: qsTr("HDR"),
                value: "hdr"
            },
            {
                label: qsTr("HDR (%1)").arg(monitor?.model || qsTr("display profile")),
                value: "hdredid"
            }
        ];
    }

    function modesOf(monitor: var): list<var> {
        const seen = new Map();
        for (const mode of monitor?.availableModes ?? []) {
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

    function nativeModeOf(monitor: var): var {
        return root.modesOf(monitor)[0] ?? null;
    }

    function scaledModesOf(monitor: var): list<var> {
        const native = root.nativeModeOf(monitor);
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

    function panelModesOf(monitor: var): list<var> {
        const native = root.nativeModeOf(monitor);
        return root.modesOf(monitor).map(mode => ({
                    width: mode.width,
                    height: mode.height,
                    mode: mode,
                    scale: 1,
                    rate: mode.rates.slice().sort((a, b) => b - a)[0],
                    native: mode === native
                }));
    }

    function shownModesOf(monitor: var, allResolutions: bool): list<var> {
        const out = root.scaledModesOf(monitor);
        const seen = new Set(out.map(entry => `${entry.width}x${entry.height}`));
        const panel = root.panelModesOf(monitor);
        const shown = allResolutions ? panel : panel.filter(entry => entry.mode.width === monitor?.width && entry.mode.height === monitor?.height);
        for (const entry of shown) {
            const size = `${entry.width}x${entry.height}`;
            if (seen.has(size))
                continue;
            seen.add(size);
            out.push(entry);
        }
        return out.sort((a, b) => b.width * b.height - a.width * a.height);
    }

    function ratesOf(monitor: var): list<var> {
        const mode = root.modesOf(monitor).find(m => m.width === monitor?.width && m.height === monitor?.height);
        return (mode?.rates ?? []).slice().sort((a, b) => b - a);
    }

    function ruleOf(name: string): var {
        return root.requested[name] ?? ({});
    }

    function valueOf(name: string, key: string): var {
        return root.ruleOf(name)[key] ?? root.ruleDefaults[key];
    }

    function numberOf(name: string, key: string): real {
        return Number(root.valueOf(name, key));
    }

    function colorProfileOf(monitor: var): string {
        return root.ruleOf(monitor?.name ?? "").cm ?? monitor?.colorManagementPreset ?? "srgb";
    }

    function reservedSideOf(name: string, side: string): int {
        const area = String(root.valueOf(name, "reserved_area"));
        const named = area.match(new RegExp(`${side}\\s*=\\s*(-?\\d+)`));
        if (named)
            return parseInt(named[1]);
        return parseInt(area) || 0;
    }

    function setReservedSide(monitor: var, side: string, size: int): void {
        const sides = ["top", "right", "bottom", "left"].map(name => `${name} = ${name === side ? size : root.reservedSideOf(monitor?.name ?? "", name)}`);
        root.applyTo(monitor, {
            reserved_area: `{ ${sides.join(", ")} }`
        });
    }

    function setColorProfile(monitor: var, profile: string): void {
        const keys = {
            cm: profile
        };
        if (profile.startsWith("hdr"))
            keys.bitdepth = 10;
        root.applyTo(monitor, keys);
    }

    function ruleForWhatIsRunning(monitor: var, size: string, rate: real): var {
        const kept = root.ruleOf(monitor.name);
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
        root.enqueueWrite(["python3", root.tool, root.file, monitor.name].concat(pairs));
    }

    function placeAll(spots: var): void {
        for (const spot of spots) {
            const monitor = HyprlandData.monitors.find(m => m.name === spot.name);
            const position = `${spot.x}x${spot.y}`;
            if (!monitor || (monitor.x === spot.x && monitor.y === spot.y && root.ruleOf(spot.name).position === position))
                continue;
            root.applyTo(monitor, {
                position: position
            });
        }
    }

    function anchorOn(name: string): void {
        const anchor = HyprlandData.monitors.find(m => m.name === name);
        if (!anchor)
            return;
        root.placeAll(HyprlandData.monitors.map(m => ({
                    name: m.name,
                    x: m.x - anchor.x,
                    y: m.y - anchor.y
                })));
    }

    function moveTo(name: string, x: int, y: int): void {
        const moved = HyprlandData.monitors.map(m => ({
                    name: m.name,
                    x: m.name === name ? x : m.x,
                    y: m.name === name ? y : m.y
                }));
        const anchor = moved.find(m => m.name === root.primary) ?? moved[0];
        if (!anchor)
            return;
        root.placeAll(moved.map(m => ({
                    name: m.name,
                    x: m.x - anchor.x,
                    y: m.y - anchor.y
                })));
    }

    function setPrimary(name: string): void {
        if (name.length === 0)
            return;
        root.enqueueWrite(["python3", root.tool, root.file, "--primary", name]);
        root.anchorOn(name);
    }

    function reload(): void {
        readProc.running = true;
    }

    property var pendingWrites: []
    property bool writing: false

    function enqueueWrite(command: var): void {
        root.pendingWrites = [...root.pendingWrites, command];
        if (!root.writing)
            root.runNextWrite();
    }

    function runNextWrite(): void {
        if (root.pendingWrites.length === 0) {
            root.writing = false;
            reloadProc.running = true;
            return;
        }
        const next = root.pendingWrites[0];
        root.pendingWrites = root.pendingWrites.slice(1);
        root.writing = true;
        persistProc.exec(next);
    }

    Process {
        id: persistProc
        onExited: root.runNextWrite()
    }

    Process {
        id: reloadProc
        command: ["hyprctl", "reload"]
        onExited: {
            HyprlandData.updateMonitors();
            root.reload();
        }
    }

    Process {
        id: readProc
        running: true
        command: ["python3", root.tool, "--read", root.file]

        stdout: StdioCollector {
            onStreamFinished: {
                const kept = JSON.parse(this.text.length > 0 ? this.text : "{}");
                root.requested = kept.monitors ?? ({});
                root.chosenPrimary = kept.primary ?? "";
            }
        }
    }

    Process {
        id: iccProc
        running: true
        command: ["python3", root.tool, "--icc-profiles"]

        stdout: StdioCollector {
            onStreamFinished: root.iccProfiles = JSON.parse(this.text.length > 0 ? this.text : "[]")
        }
    }
}
