pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.services
import qs.modules.macos.looks

Row {
    id: root

    spacing: Looks.sizes.menuBarItemSpacing

    Repeater {
        model: SystemTray.items

        MMenuBarItem {
            id: trayItem
            required property SystemTrayItem modelData

            minWidth: 30
            horizontalPadding: 5

            onClicked: event => {
                if (event.button === Qt.RightButton && trayItem.modelData.hasMenu) {
                    menuAnchor.anchor.rect = Qt.rect(trayItem.QsWindow.mapFromItem(trayItem, 0, 0).x, Looks.sizes.menuBarHeight, trayItem.width, 1);
                    menuAnchor.open();
                } else {
                    trayItem.modelData.activate();
                }
            }

            IconImage {
                anchors.verticalCenter: parent.verticalCenter
                source: trayItem.modelData.icon
                implicitSize: 18
                smooth: true
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: trayItem.modelData.menu
                anchor.window: trayItem.QsWindow.window
            }
        }
    }
}
