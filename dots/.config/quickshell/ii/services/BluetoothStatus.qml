pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    function holdAgent(hold: bool): void {
        agentProcess.running = hold;
    }

    Process {
        id: agentProcess
        command: ["bluetoothctl", "--agent", "NoInputNoOutput", "--timeout", "86400", "devices"]
    }

    function pairDevice(device: BluetoothDevice): void {
        if (!device)
            return;
        root.holdAgent(true);
        root.pairingAddress = device.address;
        pairDelay.device = device;
        pairDelay.restart();
    }

    Timer {
        id: pairDelay
        property BluetoothDevice device: null
        interval: 300
        onTriggered: pairDelay.device?.pair()
    }

    property string pairingAddress: ""
    readonly property bool pairing: root.pairingAddress.length > 0

    readonly property var pairingDevice: root.pairingAddress.length === 0 ? null : Bluetooth.devices.values.find(device => device.address === root.pairingAddress) ?? null

    function trustAndConnectOncePaired(): void {
        if (!root.pairingDevice?.paired)
            return;
        root.pairedDevice = root.pairingDevice;
        root.pairedDevice.trusted = true;
        root.pairingAddress = "";
        waitForBondingLinkToDrop.restart();
    }

    onPairingDeviceChanged: root.trustAndConnectOncePaired()

    Connections {
        target: root.pairingDevice

        function onPairedChanged(): void {
            root.trustAndConnectOncePaired();
        }
    }

    property BluetoothDevice pairedDevice: null

    Timer {
        id: waitForBondingLinkToDrop
        interval: 5000
        onTriggered: connectAfterPairing.restart()
    }

    Timer {
        id: connectAfterPairing
        property int attempts: 0
        interval: 1500
        repeat: true
        onTriggered: {
            if (!root.pairedDevice || root.pairedDevice.connected || attempts >= 4) {
                root.pairedDevice = null;
                stop();
                return;
            }
            attempts++;
            root.pairedDevice.connect();
        }
        onRunningChanged: if (running)
            attempts = 0
    }

    readonly property bool available: Bluetooth.adapters.values.length > 0
    readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property BluetoothDevice firstActiveDevice: Bluetooth.defaultAdapter?.devices.values.find(device => device.connected) ?? null
    readonly property int activeDeviceCount: Bluetooth.defaultAdapter?.devices.values.filter(device => device.connected).length ?? 0
    readonly property bool connected: Bluetooth.devices.values.some(d => d.connected)

    function sortFunction(a, b) {
        const nameIsJustTheAddress = /^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$/;
        const aIsMac = nameIsJustTheAddress.test(a.name);
        const bIsMac = nameIsJustTheAddress.test(b.name);
        if (aIsMac !== bIsMac)
            return aIsMac ? 1 : -1;

        return a.name.localeCompare(b.name);
    }
    property list<var> connectedDevices: Bluetooth.devices.values.filter(d => d.connected).sort(sortFunction)
    property list<var> pairedButNotConnectedDevices: Bluetooth.devices.values.filter(d => d.paired && !d.connected).sort(sortFunction)
    property list<var> unpairedDevices: Bluetooth.devices.values.filter(d => !d.paired && !d.connected).sort(sortFunction)
    property list<var> friendlyDeviceList: [
        ...connectedDevices,
        ...pairedButNotConnectedDevices,
        ...unpairedDevices
    ]
}
