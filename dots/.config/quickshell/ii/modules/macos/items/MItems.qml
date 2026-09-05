pragma Singleton

import QtQuick
import Quickshell
import qs.services
import qs.modules.macos.looks

Singleton {
    id: root

    readonly property list<var> all: [
        {
            id: "spaces",
            name: Translation.tr("Spaces"),
            symbol: MSymbols.spaces,
            defaultSize: "large",
            large: [4, 1]
        },
        {
            id: "keyboardLayout",
            name: Translation.tr("Keyboard Layout"),
            symbol: MSymbols.language,
            defaultSize: "normal"
        },
        {
            id: "wifi",
            name: Translation.tr("Wi-Fi"),
            symbol: MSymbols.wifi,
            defaultSize: "normal"
        },
        {
            id: "wired",
            name: Translation.tr("Ethernet"),
            symbol: MSymbols.wired,
            defaultSize: "normal"
        },
        {
            id: "bluetooth",
            name: Translation.tr("Bluetooth"),
            symbol: MSymbols.bluetooth,
            defaultSize: "normal"
        },
        {
            id: "media",
            name: Translation.tr("Now Playing"),
            symbol: MSymbols.music,
            defaultSize: "large",
            large: [2, 2]
        },
        {
            id: "volume",
            name: Translation.tr("Sound"),
            symbol: MSymbols.volume,
            defaultSize: "large",
            large: [4, 1]
        },
        {
            id: "brightness",
            name: Translation.tr("Display"),
            symbol: MSymbols.brightness,
            defaultSize: "large",
            large: [4, 1]
        },
        {
            id: "darkMode",
            name: Translation.tr("Dark Mode"),
            symbol: MSymbols.darkMode,
            defaultSize: "small"
        },
        {
            id: "nightLight",
            name: Translation.tr("Night Light"),
            symbol: MSymbols.nightLight,
            defaultSize: "small"
        },
        {
            id: "mic",
            name: Translation.tr("Microphone"),
            symbol: MSymbols.microphone,
            defaultSize: "small"
        },
        {
            id: "screenSnip",
            name: Translation.tr("Screen snip"),
            symbol: MSymbols.screenSnip,
            defaultSize: "small"
        },
        {
            id: "colorPicker",
            name: Translation.tr("Color picker"),
            symbol: MSymbols.colourPicker,
            defaultSize: "small"
        },
        {
            id: "idleInhibitor",
            name: Translation.tr("Keep awake"),
            symbol: MSymbols.idleInhibitor,
            defaultSize: "small"
        },
        {
            id: "wireGuard",
            name: Translation.tr("WireGuard"),
            symbol: MSymbols.vpn,
            defaultSize: "small"
        },
        {
            id: "cloudflareWarp",
            name: Translation.tr("Cloudflare WARP"),
            symbol: MSymbols.secureTunnel,
            defaultSize: "small"
        },
        {
            id: "easyEffects",
            name: Translation.tr("EasyEffects"),
            symbol: MSymbols.audioEffects,
            defaultSize: "small"
        },
        {
            id: "powerProfile",
            name: Translation.tr("Power Profile"),
            symbol: MSymbols.powerBalanced,
            defaultSize: "small"
        },
        {
            id: "notifications",
            name: Translation.tr("Notifications"),
            symbol: MSymbols.notifications,
            defaultSize: "small"
        },
        {
            id: "onScreenKeyboard",
            name: Translation.tr("Virtual Keyboard"),
            symbol: MSymbols.keyboard,
            defaultSize: "small"
        },
        {
            id: "battery",
            name: Translation.tr("Battery"),
            symbol: MSymbols.battery,
            defaultSize: "normal"
        },
        {
            id: "tray",
            name: Translation.tr("Tray"),
            symbol: MSymbols.tray,
            defaultSize: "large",
            large: [4, 1]
        }
    ]

    function info(id: string): var {
        return root.all.find(item => item.id === id) ?? null;
    }

    function sizeOptions(item: var): var {
        return item?.large ? ["small", "normal", "large"] : ["small", "normal"];
    }

    function span(item: var, size: string): var {
        if (size === "large" && item?.large)
            return item.large;
        if (size === "small")
            return [1, 1];
        return [2, 1];
    }

    function has(list: var, id: string): bool {
        return (list ?? []).indexOf(id) !== -1;
    }

    function withToggled(list: var, id: string): var {
        const items = (list ?? []).slice();
        const index = items.indexOf(id);
        if (index === -1)
            items.push(id);
        else
            items.splice(index, 1);
        return items;
    }

    function without(list: var, id: string): var {
        return (list ?? []).filter(existing => existing !== id);
    }

    // index counts the entries that stay put, so it is unaffected by where id sits now.
    function withInserted(list: var, id: string, index: int): var {
        const items = (list ?? []).filter(existing => existing !== id);
        const at = index < 0 ? items.length : Math.max(0, Math.min(index, items.length));
        items.splice(at, 0, id);
        return items;
    }

    function withMoved(list: var, id: string, offset: int): var {
        const items = (list ?? []).slice();
        const index = items.indexOf(id);
        const target = index + offset;
        if (index === -1 || target < 0 || target >= items.length)
            return items;
        items[index] = items[target];
        items[target] = id;
        return items;
    }
}
