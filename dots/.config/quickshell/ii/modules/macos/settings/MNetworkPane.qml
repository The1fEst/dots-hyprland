pragma ComponentBehavior: Bound

import QtQuick
import qs.services
import qs.modules.common
import qs.modules.macos.controls
import qs.modules.macos.looks

Column {
    id: root

    readonly property var active: Network.active

    // Known networks are the ones NetworkManager holds a profile for; everything else in
    // range goes below, the way macOS splits the list.
    readonly property list<var> known: Network.friendlyWifiNetworks.filter(network => Network.isSavedWifiNetwork(network.ssid))
    readonly property list<var> other: Network.friendlyWifiNetworks.filter(network => !Network.isSavedWifiNetwork(network.ssid))

    property string menuTarget: ""

    // A network we already hold a profile for joins straight away; anything else that is
    // secured needs its password first.
    function join(network: var): void {
        if (network.isSecure && !Network.isSavedWifiNetwork(network.ssid)) {
            passwordSheet.network = network;
            passwordSheet.open();
            return;
        }
        Network.connectToWifiNetwork(network);
    }

    spacing: Looks.settings.formGap

    MMenu {
        id: networkMenu

        readonly property bool autoJoin: Network.wifiAutoconnect[root.menuTarget] ?? true

        minimumWidth: 190
        entries: [
            {
                label: qsTr("Auto-Join"),
                checked: networkMenu.autoJoin,
                run: () => Network.setWifiAutoconnect(root.menuTarget, !networkMenu.autoJoin)
            },
            {
                label: qsTr("Copy Password"),
                run: () => Network.copyWifiPassword(root.menuTarget)
            },
            {
                label: qsTr("Network Settings…"),
                run: () => Quickshell.execDetached(["nm-connection-editor"])
            },
            {
                separator: true
            },
            {
                label: qsTr("Forget This Network…"),
                run: () => Network.forgetWifiNetwork(root.menuTarget)
            }
        ]
        onActivated: entry => entry.run()
    }

    MSettingsGroup {
        width: parent.width

        MSettingsRow {
            label: qsTr("Wi-Fi")
            detail: qsTr("Set up Wi-Fi to wirelessly connect this machine to the internet. Turn on Wi-Fi, then choose a network to join.")
            wrapDetail: true
            icon: "wifi"
            iconTint: "#3e8df7"

            MSwitch {
                checked: Network.wifiEnabled
                onToggled: on => Network.enableWifi(on)
            }
        }

        MSettingsRow {
            label: {
                if (!Network.wifiEnabled)
                    return qsTr("Wi-Fi is off");
                if (Network.wifiStatus === "connected")
                    return root.active?.ssid ?? Network.networkName;
                return qsTr("Not connected");
            }
            detail: Network.wifiEnabled && Network.wifiStatus === "connected" ? qsTr("Connected") : ""
            dot: Network.wifiEnabled ? Network.wifiStatus === "connected" ? Looks.colors.green : Looks.colors.orange : Looks.colors.red
            separator: false
        }
    }

    MSettingsGroup {
        width: parent.width
        visible: Network.wifiEnabled && root.known.length > 0
        title: qsTr("Known Network")

        Repeater {
            model: root.known

            MNetworkRow {
                required property var modelData
                required property int index

                network: modelData
                known: true
                separator: index < root.known.length - 1
            }
        }
    }

    MSettingsGroup {
        width: parent.width
        visible: Network.wifiEnabled && root.other.length > 0
        title: qsTr("Other Networks")

        Repeater {
            model: root.other

            MNetworkRow {
                required property var modelData
                required property int index

                network: modelData
                separator: index < root.other.length - 1
            }
        }
    }

    Item {
        width: parent.width
        height: rescan.height
        visible: Network.wifiEnabled

        MPushButton {
            id: rescan
            anchors.right: parent.right
            label: Network.wifiScanning ? qsTr("Scanning…") : qsTr("Other…")
            onClicked: addNetwork.open()
        }
    }

    MSettingsGroup {
        width: parent.width

        MSettingsRow {
            label: qsTr("Ask to join networks")
            detail: qsTr("Known networks will be joined automatically. If no known networks are available, you will be notified of available networks.")
            wrapDetail: true
            separator: false

            MPopupButton {
                current: Config.options.macos.network.askToJoin
                options: [
                    {
                        label: qsTr("Off"),
                        value: "off"
                    },
                    {
                        label: qsTr("Notify"),
                        value: "notify"
                    },
                    {
                        label: qsTr("Ask"),
                        value: "ask"
                    }
                ]
                onSelected: value => Config.options.macos.network.askToJoin = value
            }
        }
    }

    MAddNetworkSheet {
        id: addNetwork
    }

    MPasswordSheet {
        id: passwordSheet
    }

    component MNetworkRow: MSettingsRow {
        id: networkRow

        required property var network
        property bool known: false

        label: networkRow.network.ssid
        selectable: true
        selected: networkRow.network.active
        controlInset: Looks.settings.formRowControlInset

        Row {
            height: Looks.control.regular
            spacing: 12

            MPushButton {
                anchors.verticalCenter: parent.verticalCenter
                visible: networkRow.hovered && !networkRow.network.active
                label: qsTr("Connect")
                onClicked: root.join(networkRow.network)
            }

            MSymbol {
                anchors.verticalCenter: parent.verticalCenter
                visible: networkRow.network.isSecure
                symbol: "lock.fill"
                height: Looks.control.glyph.pill
                color: Looks.colors.primary
            }

            MSymbol {
                anchors.verticalCenter: parent.verticalCenter
                symbol: "wifi"
                height: Looks.control.glyph.tick
                // macOS fades the glyph rather than dropping arcs off it as the signal
                // weakens, and the flat symbol art has no arcs to drop.
                opacity: 0.4 + 0.6 * Math.min(1, networkRow.network.strength / 80)
                color: Looks.colors.primary
            }

            MSymbol {
                anchors.verticalCenter: parent.verticalCenter
                symbol: "ellipsis.circle"
                height: Looks.control.glyph.rowTrailing
                color: Looks.colors.secondary
                visible: networkRow.known

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.menuTarget = networkRow.network.ssid;
                        networkMenu.parent = parent;
                        networkMenu.x = parent.width - networkMenu.width;
                        networkMenu.y = parent.height + 4;
                        networkMenu.open();
                    }
                }
            }
        }
    }
}
