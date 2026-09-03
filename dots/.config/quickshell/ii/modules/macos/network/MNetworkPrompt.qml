pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common

// Backs the "Ask to join networks" setting. NetworkManager already joins profiles it
// holds on its own, so all that is left is what to do when none of them is in range.
Scope {
    id: root

    readonly property string mode: Config.options?.macos.network.askToJoin ?? "off"

    readonly property list<var> joinable: Network.wifiEnabled && Network.wifiStatus === "disconnected" ? Network.friendlyWifiNetworks.filter(network => !Network.isSavedWifiNetwork(network.ssid)) : []

    // One prompt per stretch of being adrift, not one per scan.
    property bool prompted: false

    onJoinableChanged: {
        if (root.joinable.length === 0) {
            root.prompted = false;
            return;
        }
        if (root.mode === "off" || root.prompted)
            return;
        root.prompted = true;
        promptDelay.restart();
    }

    Timer {
        id: promptDelay
        interval: 4000
        onTriggered: {
            if (root.joinable.length === 0)
                return;
            const names = root.joinable.slice(0, 4).map(network => network.ssid).join(", ");
            const body = qsTr("Available: %1").arg(names);
            const command = ["notify-send", "-a", "Wi-Fi", "-i", "network-wireless", qsTr("Wi-Fi Networks Available"), body];
            if (root.mode === "ask")
                command.push("-A", "join=" + qsTr("Join…"));
            prompt.exec(command);
        }
    }

    Process {
        id: prompt
        stdout: SplitParser {
            onRead: line => {
                if (line.trim() === "join")
                    Quickshell.execDetached(["qs", "-p", Quickshell.shellPath("macosSettings.qml")]);
            }
        }
    }
}
