pragma ComponentBehavior: Bound

import QtQuick
import qs.services
import qs.modules.macos.controls
import qs.modules.macos.looks

MSheet {
    id: root

    property var network: null

    readonly property string securityName: {
        const security = root.network?.security ?? "";
        return security.startsWith("WPA") ? qsTr("%1 Personal").arg(security) : security;
    }

    confirmLabel: qsTr("Join")
    confirmEnabled: password.text.length > 0

    onOpened: {
        password.text = "";
        showPassword.checked = false;
        password.forceActiveFocus();
    }

    onConfirmed: Network.connectToWifiNetwork(root.network, password.text)

    MSettingsRow {
        icon: "wifi"
        iconTint: "#3e8df7"
        label: qsTr("The Wi-Fi network “%1” requires a %2 password.").arg(root.network?.ssid ?? "").arg(root.securityName)
        emphasizedLabel: true
        wrapLabel: true
    }

    MSettingsRow {
        label: qsTr("Password")

        MTextField {
            id: password
            echoMode: showPassword.checked ? TextInput.Normal : TextInput.Password
        }
    }

    MSettingsRow {
        label: qsTr("Show password")
        separator: false

        MSwitch {
            id: showPassword
            controlHeight: Looks.control.small
            onToggled: on => checked = on
        }
    }
}
