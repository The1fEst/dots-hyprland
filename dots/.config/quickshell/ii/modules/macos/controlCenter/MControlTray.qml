pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    Row {
        anchors.centerIn: parent
        spacing: 14

        Repeater {
            model: SystemTray.items

            Item {
                id: trayItem
                required property SystemTrayItem modelData

                width: 24
                height: 24

                IconImage {
                    anchors.centerIn: parent
                    source: trayItem.modelData.icon
                    implicitSize: 22
                    smooth: true
                }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: trayItem.modelData.menu
                    anchor.window: trayItem.QsWindow.window
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: event => {
                        if (event.button === Qt.RightButton && trayItem.modelData.hasMenu) {
                            menuAnchor.anchor.rect = Qt.rect(trayItem.QsWindow.mapFromItem(trayItem, 0, 0).x, trayItem.QsWindow.mapFromItem(trayItem, 0, trayItem.height).y, trayItem.width, 1);
                            menuAnchor.open();
                            return;
                        }
                        trayItem.modelData.activate();
                    }
                }
            }
        }
    }
}
