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
                        if (deviceRow.device?.connected)
                            return Translation.tr("Connected");
                        if (deviceRow.device?.paired)
                            return Translation.tr("Paired");
                        return deviceRow.device?.address ?? "";
                    }
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            RippleButtonWithIcon {
                visible: deviceRow.device?.paired ?? false
                materialIcon: "delete"
                mainText: Translation.tr("Forget")
                onClicked: deviceRow.device?.forget()
            }

            RippleButtonWithIcon {
                materialIcon: deviceRow.device?.connected ? "bluetooth_disabled" : "bluetooth"
                mainText: deviceRow.device?.connected ? Translation.tr("Disconnect") : Translation.tr("Connect")
                onClicked: {
                    if (deviceRow.device?.connected)
                        deviceRow.device.disconnect();
                    else
                        deviceRow.device.connect();
                }
            }
        }
    }

    readonly property bool lookingForDevices: BluetoothStatus.available && BluetoothStatus.enabled

    function lookForDevices(look: bool): void {
        if (Bluetooth.defaultAdapter)
            Bluetooth.defaultAdapter.discovering = look;
    }

    onLookingForDevicesChanged: root.lookForDevices(root.lookingForDevices)
    Component.onCompleted: root.lookForDevices(root.lookingForDevices)
    Component.onDestruction: root.lookForDevices(false)

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
