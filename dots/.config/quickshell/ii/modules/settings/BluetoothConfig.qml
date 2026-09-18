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

    ContentSection {
        icon: "bluetooth"
        title: Translation.tr("Bluetooth")

        StyledText {
            visible: !BluetoothStatus.available
            Layout.leftMargin: 8
            text: Translation.tr("This machine has no Bluetooth adapter")
            color: Appearance.colors.colSubtext
        }

        ConfigSwitch {
            visible: BluetoothStatus.available
            buttonIcon: "bluetooth"
            text: Translation.tr("Bluetooth")
            checked: BluetoothStatus.enabled
            onCheckedChanged: {
                if (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled !== checked)
                    Bluetooth.defaultAdapter.enabled = checked;
            }
        }

        ConfigSwitch {
            visible: BluetoothStatus.available && BluetoothStatus.enabled
            buttonIcon: "search"
            text: Translation.tr("Look for devices")
            checked: Bluetooth.defaultAdapter?.discovering ?? false
            onCheckedChanged: {
                if (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.discovering !== checked)
                    Bluetooth.defaultAdapter.discovering = checked;
            }

            StyledToolTip {
                text: Translation.tr("Devices only show up while this is on, and they have to be in pairing mode themselves")
            }
        }
    }

    ContentSection {
        visible: BluetoothStatus.available && BluetoothStatus.enabled
        icon: "devices"
        title: Translation.tr("Devices")

        StyledText {
            visible: BluetoothStatus.friendlyDeviceList.length === 0
            Layout.leftMargin: 8
            text: Translation.tr("No devices yet")
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
