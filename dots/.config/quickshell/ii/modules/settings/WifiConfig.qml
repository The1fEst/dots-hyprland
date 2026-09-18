import QtQuick
import QtQuick.Layouts
import qs.services
import qs.services.network
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    ContentSection {
        icon: "wifi"
        title: Translation.tr("Wi-Fi")

        ConfigSwitch {
            buttonIcon: "wifi"
            text: Translation.tr("Wi-Fi")
            checked: Network.wifiEnabled
            onCheckedChanged: {
                if (checked !== Network.wifiEnabled)
                    Network.enableWifi(checked);
            }
        }

        ContentSubsection {
            visible: Network.wifiEnabled
            title: Translation.tr("Networks")

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    Layout.fillWidth: true
                    text: Network.wifiScanning ? Translation.tr("Looking for networks…") : Translation.tr("%1 in range").arg(Network.friendlyWifiNetworks.length)
                    color: Appearance.colors.colSubtext
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }

                RippleButtonWithIcon {
                    materialIcon: "refresh"
                    mainText: Translation.tr("Scan again")
                    enabled: !Network.wifiScanning
                    onClicked: Network.rescanWifi()
                }
            }

            Repeater {
                model: Network.friendlyWifiNetworks

                delegate: WifiNetworkItem {
                    required property WifiAccessPoint modelData

                    Layout.fillWidth: true
                    implicitHeight: 56 + (modelData?.askingPassword ? 110 : 0)
                    wifiNetwork: modelData
                }
            }
        }

        ContentSubsection {
            visible: Network.wifiEnabled && Network.active !== null
            title: Translation.tr("Connected network")

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    Layout.fillWidth: true
                    text: Network.active?.ssid ?? ""
                    color: Appearance.colors.colOnLayer1
                }

                RippleButtonWithIcon {
                    materialIcon: "link_off"
                    mainText: Translation.tr("Disconnect")
                    onClicked: Network.disconnectWifiNetwork()
                }

                RippleButtonWithIcon {
                    materialIcon: "delete"
                    mainText: Translation.tr("Forget")
                    onClicked: Network.forgetWifiNetwork(Network.active?.ssid ?? "")
                }
            }
        }
    }
}
