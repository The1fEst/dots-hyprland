pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Provides some system info: distro, username.
 */
Singleton {
    id: root
    property string distroName: "Unknown"
    property string distroId: "unknown"
    property string distroIcon: "linux-symbolic"
    property string username: "user"
    property string homeUrl: ""
    property string documentationUrl: ""
    property string supportUrl: ""
    property string bugReportUrl: ""
    property string privacyPolicyUrl: ""
    property string logo: ""
    property string desktopEnvironment: ""
    property string windowingSystem: ""
    property string hostname: ""
    property string kernel: ""
    property string processor: ""
    property string memory: ""
    property string graphics: ""
    property string storage: ""

    function shortDeviceName(name: string): string {
        const alias = name.match(/\[([^\]]+)\]/);
        if (alias)
            return alias[1];
        return name.replace(/,? (Corporation|Corp\.|Inc\.|Technology (Inc\.|Co\.,? Ltd\.?)|Co\.,? Ltd\.?)$/, "").trim();
    }

    function humanSize(bytes: real): string {
        const units = ["B", "KiB", "MiB", "GiB", "TiB"];
        let value = bytes;
        let unit = 0;
        while (value >= 1024 && unit < units.length - 1) {
            value /= 1024;
            unit++;
        }
        return `${value.toFixed(unit === 0 || value >= 100 ? 0 : 1)} ${units[unit]}`;
    }

    Timer {
        triggeredOnStart: true
        interval: 1
        running: true
        repeat: false
        onTriggered: {
            getUsername.running = true
            fileOsRelease.reload()
            const textOsRelease = fileOsRelease.text()

            // Extract the friendly name (PRETTY_NAME field, fallback to NAME)
            const prettyNameMatch = textOsRelease.match(/^PRETTY_NAME="(.+?)"/m)
            const nameMatch = textOsRelease.match(/^NAME="(.+?)"/m)
            distroName = prettyNameMatch ? prettyNameMatch[1] : (nameMatch ? nameMatch[1].replace(/Linux/i, "").trim() : "Unknown")

            // Extract the ID
            const idMatch = textOsRelease.match(/^ID="?(.+?)"?$/m)
            distroId = idMatch ? idMatch[1] : "unknown"

            // Extract additional URLs and logo
            const homeUrlMatch = textOsRelease.match(/^HOME_URL="(.+?)"/m)
            homeUrl = homeUrlMatch ? homeUrlMatch[1] : ""
            const documentationUrlMatch = textOsRelease.match(/^DOCUMENTATION_URL="(.+?)"/m)
            documentationUrl = documentationUrlMatch ? documentationUrlMatch[1] : ""
            const supportUrlMatch = textOsRelease.match(/^SUPPORT_URL="(.+?)"/m)
            supportUrl = supportUrlMatch ? supportUrlMatch[1] : ""
            const bugReportUrlMatch = textOsRelease.match(/^BUG_REPORT_URL="(.+?)"/m)
            bugReportUrl = bugReportUrlMatch ? bugReportUrlMatch[1] : ""
            const privacyPolicyUrlMatch = textOsRelease.match(/^PRIVACY_POLICY_URL="(.+?)"/m)
            privacyPolicyUrl = privacyPolicyUrlMatch ? privacyPolicyUrlMatch[1] : ""
            const logoFieldMatch = textOsRelease.match(/^LOGO="?(.+?)"?$/m)
            logo = logoFieldMatch ? logoFieldMatch[1] : ""

            // Update the distroIcon property based on distroId
            switch (distroId) {
                case "artix":
                case "arch": distroIcon = "arch-symbolic"; break;
                case "manjaro": distroIcon = "manjaro-symbolic"; break;
                case "endeavouros": distroIcon = "endeavouros-symbolic"; break;
                case "cachyos": distroIcon = "cachyos-symbolic"; break;
                case "nixos": distroIcon = "nixos-symbolic"; break;
                case "fedora": distroIcon = "fedora-symbolic"; break;
                case "linuxmint":
                case "ubuntu":
                case "zorin":
                case "popos": distroIcon = "ubuntu-symbolic"; break;
                case "debian":
                case "raspbian":
                case "kali": distroIcon = "debian-symbolic"; break;
                case "funtoo":
                case "gentoo": distroIcon = "gentoo-symbolic"; break;
                default: distroIcon = "linux-symbolic"; break;
            }
            if (textOsRelease.toLowerCase().includes("nyarch")) {
                distroIcon = "nyarch-symbolic"
            }

            if (logo.trim().length === 0) {
                logo = distroIcon
            }

        }
    }

    Process {
        id: getUsername
        command: ["whoami"]
        stdout: SplitParser {
            onRead: data => {
                root.username = data.trim()
            }
        }
    }

    Process {
        id: getDesktopEnvironment
        running: true
        command: ["bash", "-c", "echo $XDG_CURRENT_DESKTOP,$WAYLAND_DISPLAY"]
        stdout: StdioCollector {
            id: deCollector
            onStreamFinished: {
                const [desktop, wayland] = deCollector.text.split(",")
                root.desktopEnvironment = desktop.trim()
                root.windowingSystem = wayland.trim().length > 0 ? "Wayland" : "X11" // Are there others? 🤔
            }
        }
    }

    Process {
        id: getMachine
        running: true
        command: ["bash", "-c", "uname -n; uname -r; sed -n 's/^model name[ \\t]*: //p' /proc/cpuinfo | head -1; awk '/MemTotal/ {print $2}' /proc/meminfo"]
        stdout: StdioCollector {
            id: machineCollector
            onStreamFinished: {
                const lines = machineCollector.text.split("\n");
                root.hostname = (lines[0] ?? "").trim();
                root.kernel = (lines[1] ?? "").trim();
                root.processor = (lines[2] ?? "").trim();
                const kilobytes = parseInt(lines[3] ?? "0");
                root.memory = kilobytes > 0 ? `${(kilobytes / 1024 / 1024).toFixed(1)} GiB` : "";
            }
        }
    }

    Process {
        id: getGraphics
        running: true
        command: ["bash", "-c", "lspci -mm | awk -F'\"' '$2 ~ /^(VGA compatible controller|3D controller|Display controller)$/ {print $4 \"\\t\" $6}'"]
        stdout: StdioCollector {
            id: graphicsCollector
            onStreamFinished: {
                root.graphics = graphicsCollector.text.trim().split("\n").filter(line => line.length > 0).map(line => {
                    const [vendor, device] = line.split("\t");
                    return `${root.shortDeviceName(vendor ?? "")} ${root.shortDeviceName(device ?? "")}`.trim();
                }).join(", ");
            }
        }
    }

    Process {
        id: getStorage
        running: true
        command: ["bash", "-c", "df -B1 --output=used,size / | tail -1"]
        stdout: StdioCollector {
            id: storageCollector
            onStreamFinished: {
                const [used, size] = storageCollector.text.trim().split(/\s+/).map(field => parseInt(field));
                if (!(size > 0))
                    return;
                root.storage = `${root.humanSize(used)} / ${root.humanSize(size)} (${Math.round(used / size * 100)}%)`;
            }
        }
    }

    FileView {
        id: fileOsRelease
        path: "/etc/os-release"
    }
}