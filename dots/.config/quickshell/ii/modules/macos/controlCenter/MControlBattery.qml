pragma ComponentBehavior: Bound

import QtQuick
import qs.services
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    readonly property color accent: Battery.isLowAndNotCharging ? Looks.colors.red : (Battery.isCharging ? Looks.colors.green : Looks.colors.primary)

    Row {
        anchors.centerIn: parent
        spacing: 8

        MSymbol {
            anchors.verticalCenter: parent.verticalCenter
            symbol: Battery.available ? (Battery.isCharging ? MSymbols.batteryCharging : MSymbols.battery) : MSymbols.batteryUnknown
            width: 24
            height: Looks.control.glyph.tileWide
            color: root.accent
        }

        MText {
            anchors.verticalCenter: parent.verticalCenter
            visible: Battery.available
            text: `${Math.round(Battery.percentage * 100)}%`
            font.pixelSize: Looks.font.style.title3.size
            emphasized: true
            color: root.accent
        }
    }
}
