pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Bluetooth
import qs.services
import qs.modules.macos.controls
import qs.modules.macos.looks

Column {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool poweredOn: BluetoothStatus.enabled

    readonly property list<var> known: root.poweredOn ? [...BluetoothStatus.connectedDevices, ...BluetoothStatus.pairedButNotConnectedDevices] : []
    readonly property list<var> nearby: root.poweredOn ? BluetoothStatus.unpairedDevices : []

    function beDiscoverableAndScan(on: bool): void {
        BluetoothStatus.holdAgent(on);
        if (!root.adapter)
            return;
        if (root.adapter.discovering !== on)
            root.adapter.discovering = on;
        if (root.adapter.discoverable !== on)
            root.adapter.discoverable = on;
        if (root.adapter.pairable !== on)
            root.adapter.pairable = on;
    }

    Component.onDestruction: root.beDiscoverableAndScan(false)

    Timer {
        running: true
        interval: 2000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.beDiscoverableAndScan(root.poweredOn)
    }

    function deviceGlyph(device: var): string {
        const icon = device?.icon ?? "";
        if (icon.includes("headset") || icon.includes("headphones"))
            return "headphones";
        if (icon.includes("audio"))
            return "hifispeaker";
        if (icon.includes("phone"))
            return "iphone";
        if (icon.includes("mouse"))
            return "computermouse";
        if (icon.includes("keyboard"))
            return "keyboard";
        if (icon.includes("computer"))
            return "display";
        if (icon.includes("gaming") || icon.includes("joypad"))
            return "gamecontroller";
        return "bluetooth";
    }

    function deviceStatus(device: var): string {
        if (device.connected)
            return device.batteryAvailable ? qsTr("Connected — %1%").arg(Math.round(device.battery * 100)) : qsTr("Connected");
        return device.paired ? qsTr("Not Connected") : "";
    }

    spacing: Looks.settings.formGap

    MSettingsGroup {
        width: parent.width

        MSettingsRow {
            label: qsTr("Bluetooth")
            detail: qsTr("Connect to accessories you can use for activities such as streaming music, typing, and gaming.")
            wrapDetail: true
            icon: "bluetooth"
            iconTint: "#3e8df7"
            separator: root.poweredOn

            MSwitch {
                controlHeight: Looks.control.small
                checked: root.poweredOn
                onToggled: on => {
                    if (root.adapter)
                        root.adapter.enabled = on;
                }
            }
        }

        MSettingsRow {
            separator: false
            visible: root.poweredOn
            note: qsTr("This machine is discoverable as “%1” while Bluetooth Settings is open.").arg(root.adapter?.name ?? "")
        }
    }

    MSettingsGroup {
        width: parent.width
        visible: root.known.length > 0
        title: qsTr("My Devices")

        Repeater {
            model: root.known

            MDeviceRow {
                required property var modelData
                required property int index

                device: modelData
                separator: index < root.known.length - 1
            }
        }
    }

    MSettingsGroup {
        width: parent.width
        visible: root.poweredOn
        title: qsTr("Nearby Devices")
        busy: root.adapter?.discovering ?? false

        MSettingsRow {
            visible: root.nearby.length === 0
            separator: false
            placeholder: qsTr("Searching…")
        }

        Repeater {
            model: root.nearby

            MDeviceRow {
                required property var modelData
                required property int index

                device: modelData
                separator: index < root.nearby.length - 1
            }
        }
    }

    MDeviceSheet {
        id: deviceSheet
    }

    component MDeviceRow: MSettingsRow {
        id: deviceRow

        required property var device

        label: deviceRow.device.name
        detail: root.deviceStatus(deviceRow.device)
        glyph: root.deviceGlyph(deviceRow.device)
        controlInset: Looks.settings.formRowGlyphInset

        Row {
            height: Looks.control.regular
            spacing: 12

            MPushButton {
                readonly property bool waiting: BluetoothStatus.pairingAddress === deviceRow.device.address

                anchors.verticalCenter: parent.verticalCenter
                visible: deviceRow.hovered || waiting
                label: {
                    if (waiting)
                        return qsTr("Pairing…");
                    if (deviceRow.device.connected)
                        return qsTr("Disconnect");
                    return deviceRow.device.paired ? qsTr("Connect") : qsTr("Pair");
                }
                onClicked: {
                    if (waiting)
                        return;
                    if (deviceRow.device.connected)
                        deviceRow.device.disconnect();
                    else if (deviceRow.device.paired)
                        deviceRow.device.connect();
                    else
                        BluetoothStatus.pairDevice(deviceRow.device);
                }
            }

            MSymbol {
                anchors.verticalCenter: parent.verticalCenter
                visible: deviceRow.device.paired
                symbol: "info.circle"
                height: Looks.control.glyph.rowTrailing
                color: Looks.colors.secondary

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        deviceSheet.device = deviceRow.device;
                        deviceSheet.open();
                    }
                }
            }
        }
    }
}
