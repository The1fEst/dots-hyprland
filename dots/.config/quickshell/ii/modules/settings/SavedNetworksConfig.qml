import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    component SavedNetworkRow: Rectangle {
        id: savedRow

        required property string ssid

        readonly property bool automatic: Network.wifiAutoconnect[savedRow.ssid] ?? true

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
                text: Network.active?.ssid === savedRow.ssid ? "wifi" : "wifi_lock"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnLayer2
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: savedRow.ssid
                    elide: Text.ElideRight
                    color: Appearance.colors.colOnLayer2
                }

                StyledText {
                    Layout.fillWidth: true
                    text: {
                        if (Network.active?.ssid === savedRow.ssid)
                            return Translation.tr("Connected");
                        return savedRow.automatic ? Translation.tr("Joins on its own") : Translation.tr("Only when chosen");
                    }
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            OptionSwitch {
                buttonIcon: "autorenew"
                text: Translation.tr("Automatic")
                current: savedRow.automatic
                onCommitted: wanted => Network.setWifiAutoconnect(savedRow.ssid, wanted)

                StyledToolTip {
                    text: Translation.tr("Join this network whenever it is in range")
                }
            }

            RippleButtonWithIcon {
                materialIcon: "delete"
                mainText: Translation.tr("Forget")
                onClicked: Network.forgetWifiNetwork(savedRow.ssid)
            }
        }
    }

    ContentPlaceholder {
        visible: Network.savedWifiNetworks.length === 0
        icon: "wifi_off"
        title: Translation.tr("No Saved Networks")
        description: Translation.tr("Saved Wi-Fi networks will appear here")
    }

    ContentSection {
        visible: Network.savedWifiNetworks.length > 0

        Repeater {
            model: Network.savedWifiNetworks

            delegate: SavedNetworkRow {
                required property string modelData
                ssid: modelData
            }
        }
    }
}
