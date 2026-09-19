import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    component ConnectionRow: Rectangle {
        id: connectionRow

        required property var connection

        Layout.fillWidth: true
        implicitHeight: 52
        radius: Appearance.rounding.small
        color: Appearance.colors.colLayer2

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 12
                rightMargin: 8
            }
            spacing: 10

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: connectionRow.connection.name
                    elide: Text.ElideRight
                    color: Appearance.colors.colOnLayer2
                }

                StyledText {
                    Layout.fillWidth: true
                    text: connectionRow.connection.active ? Translation.tr("Connected · %1").arg(connectionRow.connection.device) : Translation.tr("Not connected")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colSubtext
                }
            }

            StyledSwitch {
                id: activeSwitch
                checked: connectionRow.connection.active
                onClicked: {
                    activeSwitch.checked = Qt.binding(() => connectionRow.connection.active);
                    if (connectionRow.connection.active)
                        NetworkConnections.deactivate(connectionRow.connection.name);
                    else
                        NetworkConnections.activate(connectionRow.connection.name);
                }
            }
        }
    }

    ContentSection {
        icon: "lan"
        title: Translation.tr("Wired")

        StyledText {
            visible: NetworkConnections.wiredConnections.length === 0
            Layout.leftMargin: 8
            text: Translation.tr("No wired connection is set up")
            color: Appearance.colors.colSubtext
        }

        Repeater {
            model: NetworkConnections.wiredConnections

            delegate: ConnectionRow {
                required property var modelData
                connection: modelData
            }
        }
    }

    ContentSection {
        icon: "vpn_key"
        title: Translation.tr("VPN")

        StyledText {
            visible: NetworkConnections.vpnConnections.length === 0
            Layout.leftMargin: 8
            text: Translation.tr("No VPN is set up")
            color: Appearance.colors.colSubtext
        }

        Repeater {
            model: NetworkConnections.vpnConnections

            delegate: ConnectionRow {
                required property var modelData
                connection: modelData
            }
        }

        RippleButtonWithIcon {
            Layout.topMargin: 4
            materialIcon: "settings_ethernet"
            mainText: Translation.tr("Set up connections")
            onClicked: Quickshell.execDetached(["bash", "-c", Config.options.apps.network])

            StyledToolTip {
                text: Translation.tr("Adding and editing connections is NetworkManager's own job")
            }
        }
    }
}
