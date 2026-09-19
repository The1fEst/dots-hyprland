pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * The connections NetworkManager knows about, the kind each one is and whether it
 * is up right now.
 */
Singleton {
    id: root

    property var connections: []

    readonly property var vpnTypes: ["vpn", "wireguard", "tun", "ip-tunnel"]

    readonly property var vpnConnections: root.connections.filter(connection => root.vpnTypes.includes(connection.type))
    readonly property var wiredConnections: root.connections.filter(connection => connection.type === "802-3-ethernet")

    function activate(name: string): void {
        actionProc.exec(["nmcli", "connection", "up", name]);
    }

    function deactivate(name: string): void {
        actionProc.exec(["nmcli", "connection", "down", name]);
    }

    function refresh(): void {
        readProc.running = true;
    }

    Process {
        id: readProc
        running: true
        command: ["nmcli", "-t", "-f", "NAME,TYPE,ACTIVE,DEVICE", "connection", "show"]

        stdout: StdioCollector {
            onStreamFinished: {
                const found = [];
                for (const line of this.text.split("\n")) {
                    if (line.trim().length === 0)
                        continue;
                    const fields = line.split(":");
                    if (fields.length < 3 || fields[1] === "loopback")
                        continue;
                    found.push({
                        name: fields[0],
                        type: fields[1],
                        active: fields[2] === "yes",
                        device: fields[3] ?? ""
                    });
                }
                found.sort((first, second) => first.name.localeCompare(second.name));
                root.connections = found;
            }
        }
    }

    Process {
        id: actionProc
        onExited: refreshTimer.restart()
    }

    Timer {
        id: refreshTimer
        interval: 500
        onTriggered: root.refresh()
    }

    Process {
        running: true
        command: ["nmcli", "monitor"]

        stdout: SplitParser {
            onRead: refreshTimer.restart()
        }
    }
}
