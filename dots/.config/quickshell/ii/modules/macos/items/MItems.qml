pragma Singleton

import QtQuick
import Quickshell
import qs.services

Singleton {
    id: root

    readonly property list<var> all: [
        {
            id: "spaces",
            name: Translation.tr("Spaces"),
            icon: "grid_view",
            defaultSize: "large",
            large: [4, 1]
        },
        {
            id: "wifi",
            name: Translation.tr("Wi-Fi"),
            icon: "wifi",
            defaultSize: "normal"
        },
        {
            id: "wired",
            name: Translation.tr("Ethernet"),
            icon: "lan",
            defaultSize: "normal"
        },
        {
            id: "bluetooth",
            name: Translation.tr("Bluetooth"),
            icon: "bluetooth",
            defaultSize: "normal"
        },
        {
            id: "media",
            name: Translation.tr("Now Playing"),
            icon: "music_note",
            defaultSize: "large",
            large: [2, 2]
        },
        {
            id: "volume",
            name: Translation.tr("Sound"),
            icon: "volume_up",
            defaultSize: "large",
            large: [4, 1]
        },
        {
            id: "brightness",
            name: Translation.tr("Display"),
            icon: "brightness_high",
            defaultSize: "large",
            large: [4, 1]
        },
        {
            id: "darkMode",
            name: Translation.tr("Dark Mode"),
            icon: "contrast",
            defaultSize: "small"
        },
        {
            id: "nightLight",
            name: Translation.tr("Night Light"),
            icon: "bedtime",
            defaultSize: "small"
        },
        {
            id: "mic",
            name: Translation.tr("Microphone"),
            icon: "mic",
            defaultSize: "small"
        },
        {
            id: "screenSnip",
            name: Translation.tr("Screen snip"),
            icon: "screenshot_region",
            defaultSize: "small"
        },
        {
            id: "colorPicker",
            name: Translation.tr("Color picker"),
            icon: "colorize",
            defaultSize: "small"
        },
        {
            id: "idleInhibitor",
            name: Translation.tr("Keep awake"),
            icon: "coffee",
            defaultSize: "small"
        },
        {
            id: "wireGuard",
            name: Translation.tr("WireGuard"),
            icon: "vpn_key",
            defaultSize: "small"
        },
        {
            id: "cloudflareWarp",
            name: Translation.tr("Cloudflare WARP"),
            icon: "cloud_lock",
            defaultSize: "small"
        },
        {
            id: "easyEffects",
            name: Translation.tr("EasyEffects"),
            icon: "graphic_eq",
            defaultSize: "small"
        },
        {
            id: "powerProfile",
            name: Translation.tr("Power Profile"),
            icon: "airwave",
            defaultSize: "small"
        },
        {
            id: "notifications",
            name: Translation.tr("Notifications"),
            icon: "notifications_active",
            defaultSize: "small"
        },
        {
            id: "onScreenKeyboard",
            name: Translation.tr("Virtual Keyboard"),
            icon: "keyboard",
            defaultSize: "small"
        },
        {
            id: "battery",
            name: Translation.tr("Battery"),
            icon: "battery_full",
            defaultSize: "normal"
        },
        {
            id: "tray",
            name: Translation.tr("Tray"),
            icon: "widgets",
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
