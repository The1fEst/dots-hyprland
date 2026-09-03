pragma ComponentBehavior: Bound

import QtQuick
import qs.services
import qs.modules.macos.controls
import qs.modules.macos.looks

MSheet {
    id: root

    confirmEnabled: name.text.length > 0

    onOpened: {
        name.text = "";
        password.text = "";
        showPassword.checked = false;
        name.forceActiveFocus();
    }

    onConfirmed: Network.connectToHiddenNetwork(name.text, password.text, security.value)

    MSettingsRow {
        icon: "wifi"
        iconTint: "#3e8df7"
        label: qsTr("Add a Wi-Fi Network Profile")
        detail: qsTr("Enter the name and the security type of the profile you want to add.")
        wrapDetail: true
        emphasizedLabel: true
    }

    MSettingsRow {
        label: qsTr("Network Name")

        MTextField {
            id: name
        }
    }

    MSettingsRow {
        label: qsTr("Security")

        MPopupButton {
            id: security
            controlHeight: Looks.control.small
            value: qsTr("WPA2/WPA3 Personal")
        }
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
