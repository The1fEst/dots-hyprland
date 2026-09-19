import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    component DeviceRow: Rectangle {
        id: deviceRow

        required property var device

        readonly property bool pairing: BluetoothStatus.pairing && BluetoothStatus.pairingAddress === deviceRow.device?.address

        readonly property bool connecting: deviceRow.device?.state === BluetoothDeviceState.Connecting

        property bool asked: false
        property bool refused: false

        Connections {
            target: deviceRow.device

            function onStateChanged(): void {
                if (deviceRow.device.state === BluetoothDeviceState.Connected) {
                    deviceRow.asked = false;
                    deviceRow.refused = false;
                } else if (deviceRow.device.state === BluetoothDeviceState.Disconnected && deviceRow.asked) {
                    deviceRow.asked = false;
                    deviceRow.refused = true;
                }
            }
        }

        Layout.fillWidth: true
        implicitHeight: 56
        radius: Appearance.rounding.small
        color: Appearance.colors.colLayer2

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 12
                rightMargin: 8
            }
            spacing: 10

            MaterialSymbol {
                text: deviceRow.device?.icon?.length > 0 ? "bluetooth_connected" : "bluetooth"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnLayer2
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: deviceRow.device?.name ?? deviceRow.device?.address ?? ""
                    elide: Text.ElideRight
                    color: Appearance.colors.colOnLayer2
                }

                StyledText {
                    Layout.fillWidth: true
                    text: {
                        if (deviceRow.pairing)
                            return Translation.tr("Pairing…");
                        if (deviceRow.connecting)
                            return Translation.tr("Connecting…");
                        if (deviceRow.device?.connected)
                            return Translation.tr("Connected");
                        if (deviceRow.refused)
                            return Translation.tr("Could not connect. Wake the device and try again");
                        if (deviceRow.device?.paired)
                            return Translation.tr("Paired");
                        return Translation.tr("Not set up");
                    }
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: deviceRow.refused ? Appearance.colors.colError : Appearance.colors.colSubtext
                }
            }

            RippleButtonWithIcon {
                visible: deviceRow.device?.paired ?? false
                materialIcon: "delete"
                mainText: Translation.tr("Forget")
                onClicked: deviceRow.device?.forget()
            }

            RippleButtonWithIcon {
                enabled: !deviceRow.pairing && !deviceRow.connecting
                materialIcon: {
                    if (!deviceRow.device?.paired)
                        return "link";
                    return deviceRow.device?.connected ? "bluetooth_disabled" : "bluetooth";
                }
                mainText: {
                    if (!deviceRow.device?.paired)
                        return Translation.tr("Pair");
                    return deviceRow.device?.connected ? Translation.tr("Disconnect") : Translation.tr("Connect");
                }
                onClicked: {
                    if (!deviceRow.device?.paired) {
                        BluetoothStatus.pairDevice(deviceRow.device);
                        return;
                    }
                    if (deviceRow.device.connected) {
                        deviceRow.device.disconnect();
                        return;
                    }
                    deviceRow.asked = true;
                    deviceRow.refused = false;
                    BluetoothStatus.connectDevice(deviceRow.device);
                }
            }
        }
    }

    readonly property bool settingUpDevice: BluetoothStatus.pairing || BluetoothStatus.pairedDevice !== null || BluetoothStatus.connectingDevice !== null

    readonly property bool lookingForDevices: BluetoothStatus.available && BluetoothStatus.enabled && !root.settingUpDevice

    function lookForDevices(look: bool): void {
        if (Bluetooth.defaultAdapter)
            Bluetooth.defaultAdapter.discovering = look;
    }

    onLookingForDevicesChanged: if (!root.lookingForDevices)
        root.lookForDevices(false)

    Component.onDestruction: root.lookForDevices(false)

    Timer {
        running: root.lookingForDevices && !(Bluetooth.defaultAdapter?.discovering ?? false)
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.lookForDevices(true)
    }

    ContentSection {
        visible: BluetoothStatus.available

        ConfigSwitch {
            buttonIcon: "bluetooth"
            text: Translation.tr("Bluetooth")
            checked: BluetoothStatus.enabled
            onCheckedChanged: {
                if (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled !== checked)
                    Bluetooth.defaultAdapter.enabled = checked;
            }
        }
    }

    ContentPlaceholder {
        visible: !BluetoothStatus.available
        icon: "bluetooth_disabled"
        title: Translation.tr("No Bluetooth Found")
        description: Translation.tr("Plug in a dongle to use Bluetooth")
    }

    ContentPlaceholder {
        visible: BluetoothStatus.available && !BluetoothStatus.enabled
        icon: "bluetooth_disabled"
        title: Translation.tr("Bluetooth Turned Off")
        description: Translation.tr("Turn on to connect devices and receive file transfers")
    }

    ContentSection {
        visible: BluetoothStatus.available && BluetoothStatus.enabled
        icon: "devices"
        title: Translation.tr("Devices")
        busy: Bluetooth.defaultAdapter?.discovering ?? false

        StyledText {
            visible: BluetoothStatus.friendlyDeviceList.length === 0
            Layout.leftMargin: 8
            text: Translation.tr("Searching for devices…")
            color: Appearance.colors.colSubtext
        }

        Repeater {
            model: BluetoothStatus.friendlyDeviceList

            delegate: DeviceRow {
                required property var modelData
                device: modelData
            }
        }
    }
}
