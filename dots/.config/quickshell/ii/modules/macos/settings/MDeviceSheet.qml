pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.controls
import qs.modules.macos.looks

MSheet {
    id: root

    property var device: null

    cancelLabel: qsTr("Done")
    confirmLabel: qsTr("Forget This Device")

    onConfirmed: root.device?.forget()

    MSettingsRow {
        label: root.device?.name ?? ""
        emphasizedLabel: true
        detail: root.device?.address ?? ""
        glyph: "info.circle"
    }

    MSettingsRow {
        label: qsTr("Connected")
        value: root.device?.connected ? qsTr("Yes") : qsTr("No")
    }

    MSettingsRow {
        label: qsTr("Battery")
        visible: root.device?.batteryAvailable ?? false
        value: root.device?.batteryAvailable ? qsTr("%1%").arg(Math.round(root.device.battery * 100)) : ""
        separator: false
    }
}
