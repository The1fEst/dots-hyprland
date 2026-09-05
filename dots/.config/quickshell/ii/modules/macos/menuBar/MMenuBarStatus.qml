pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules.common.widgets
import qs.modules.macos.looks

MMenuBarItem {
    id: root

    required property QtObject toggleModel
    required property string symbol
    property string settingsCommand: ""

    minWidth: 30
    horizontalPadding: 5
    interactive: root.toggleModel.available
    opacity: root.toggleModel.available ? 1 : 0.4

    onClicked: event => {
        if (event.button === Qt.RightButton && root.settingsCommand.length > 0)
            Quickshell.execDetached(["bash", "-c", root.settingsCommand]);
        else if (event.button === Qt.RightButton && root.toggleModel.altAction)
            root.toggleModel.altAction();
        else
            root.toggleModel.mainAction();
    }

    MSymbol {
        anchors.verticalCenter: parent.verticalCenter
        symbol: root.symbol
        width: Looks.control.glyph.menuBar
        height: Looks.control.glyph.menuBar
        color: Looks.colors.primary
    }
}
