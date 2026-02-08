import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import Quickshell

WindowDialog {
    id: root
    backgroundHeight: 400

    WindowDialogTitle {
        text: Translation.tr("WireGuard Connections")
    }

    WindowDialogSeparator {}

    ListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16
        Layout.leftMargin: -Appearance.rounding.large
        Layout.rightMargin: -Appearance.rounding.large

        clip: true
        spacing: 0

        model: connectionModel

        delegate: DialogListItem {
            id: delegateItem
            width: ListView.view.width
            active: model.active

            onClicked: {
                if (model.active) {
                    Quickshell.execDetached(["nmcli", "connection", "down", model.name])
                } else {
                    Quickshell.execDetached(["nmcli", "connection", "up", model.name])
                }
                refreshTimer.restart()
            }

            contentItem: RowLayout {
                anchors {
                    fill: parent
                    topMargin: delegateItem.verticalPadding
                    bottomMargin: delegateItem.verticalPadding
                    leftMargin: delegateItem.horizontalPadding
                    rightMargin: delegateItem.horizontalPadding
                }
                spacing: 10

                CustomIcon {
                    source: 'wireguard-symbolic'
                    Layout.preferredWidth: Appearance.font.pixelSize.larger
                    Layout.preferredHeight: Appearance.font.pixelSize.larger
                    colorize: true
                    color: Appearance.colors.colOnSurfaceVariant
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    StyledText {
                        Layout.fillWidth: true
                        color: Appearance.colors.colOnSurfaceVariant
                        elide: Text.ElideRight
                        text: model.name
                        textFormat: Text.PlainText
                    }
                    StyledText {
                        Layout.fillWidth: true
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                        elide: Text.ElideRight
                        text: model.active ? Translation.tr("Connected") : Translation.tr("Disconnected")
                    }
                }

                MaterialSymbol {
                    text: model.active ? "check" : ""
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnSurfaceVariant
                    visible: model.active
                }
            }
        }
    }

    property var connectionModel: ListModel {}

    Timer {
        id: refreshTimer
        interval: 1000
        onTriggered: refreshConnections.running = true
    }

    Process {
        id: listConnections
        running: true
        command: ["bash", "-c", "nmcli -t -f NAME,TYPE connection show | grep ':wireguard$' | cut -d: -f1"]
        stdout: StdioCollector {
            id: connListCollector
            onStreamFinished: {
                const text = connListCollector.text.trim();
                const connections = text.length > 0 ? text.split('\n') : [];
                refreshConnections.connections = connections
                refreshConnections.running = true
            }
        }
    }

    Process {
        id: refreshConnections
        property var connections: []
        
        command: ["bash", "-c", "nmcli -t -f NAME connection show --active"]
        stdout: StdioCollector {
            id: activeCollector
            onStreamFinished: {
                const text = activeCollector.text.trim();
                const activeConns = text.length > 0 ? text.split('\n') : [];
                root.connectionModel.clear();
                
                for (const conn of refreshConnections.connections) {
                    const isActive = activeConns.includes(conn);
                    root.connectionModel.append({name: conn, active: isActive});
                }
            }
        }
    }

    WindowDialogSeparator {}
    WindowDialogButtonRow {
        DialogButton {
            buttonText: Translation.tr("New Connection")
            onClicked: {
                Quickshell.execDetached(["bash", "-c", Config.options.apps.network]);
                GlobalStates.sidebarRightOpen = false;
            }
        }

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: Translation.tr("Done")
            onClicked: root.dismiss()
        }
    }
}
