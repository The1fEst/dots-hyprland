import QtQuick
import QtQuick.Layouts
import qs.services
import qs.services.network
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    Timer {
        running: Network.wifiEnabled
        interval: 15000
        repeat: true
        triggeredOnStart: true
        onTriggered: Network.rescanWifi()
    }

    ContentSection {
        ConfigSwitch {
            buttonIcon: "wifi"
            text: Translation.tr("Wi-Fi")
            checked: Network.wifiEnabled
            onCheckedChanged: {
                if (checked !== Network.wifiEnabled)
                    Network.enableWifi(checked);
            }
        }

        ContentLinkRow {
            buttonIcon: "bookmark"
            title: Translation.tr("Saved Networks")
            onClicked: root.subpageRequested(title, "modules/settings/SavedNetworksConfig.qml")
        }

        ContentLinkRow {
            buttonIcon: "wifi_password"
            title: Translation.tr("Connect to Hidden Network…")
            onClicked: root.subpageRequested(title, "modules/settings/HiddenNetworkConfig.qml")
        }
    }

    ContentPlaceholder {
        visible: !Network.wifiEnabled
        icon: "signal_wifi_off"
        title: Translation.tr("Wi-Fi Off")
        description: Translation.tr("Turn on to use Wi-Fi")
    }

    ContentSection {
        visible: Network.wifiEnabled
        icon: "wifi_find"
        title: Translation.tr("Visible Networks")
        busy: Network.wifiScanning

        StyledText {
            visible: Network.friendlyWifiNetworks.length === 0
            Layout.leftMargin: 8
            text: Translation.tr("Searching for networks…")
            color: Appearance.colors.colSubtext
        }

        Repeater {
            model: Network.friendlyWifiNetworks

            delegate: WifiNetworkItem {
                required property WifiAccessPoint modelData

                Layout.fillWidth: true
                implicitHeight: 56 + (modelData?.askingPassword ? 110 : 0)
                wifiNetwork: modelData
                showActions: true
            }
        }
    }
}
