import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    function join(): void {
        const ssid = ssidField.text.trim();
        if (ssid.length === 0)
            return;
        Network.connectToHiddenNetwork(ssid, passwordField.text, "");
        passwordField.text = "";
    }

    ContentSection {
        ContentSubsectionLabel {
            text: Translation.tr("A hidden network does not announce itself, so it has to be named in full")
        }

        ContentSubsection {
            title: Translation.tr("Network name")

            MaterialTextField {
                id: ssidField
                Layout.fillWidth: true
                placeholderText: Translation.tr("Name of the network")
                onAccepted: root.join()
            }
        }

        ContentSubsection {
            title: Translation.tr("Password")
            tooltip: Translation.tr("Leave empty for a network without one")

            MaterialTextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: Translation.tr("Password")
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData
                onAccepted: root.join()
            }
        }

        RippleButtonWithIcon {
            Layout.topMargin: 4
            enabled: ssidField.text.trim().length > 0 && !Network.hiddenConnecting
            materialIcon: "wifi_add"
            mainText: Network.hiddenConnecting ? Translation.tr("Connecting…") : Translation.tr("Connect")
            onClicked: root.join()
        }

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            visible: !Network.hiddenConnecting && Network.hiddenConnectStatus.length > 0
            wrapMode: Text.Wrap
            text: Network.hiddenConnectStatus === "ok" ? Translation.tr("Connected") : Network.hiddenConnectStatus
            color: Network.hiddenConnectStatus === "ok" ? Appearance.colors.colSubtext : Appearance.colors.colError
        }
    }
}
