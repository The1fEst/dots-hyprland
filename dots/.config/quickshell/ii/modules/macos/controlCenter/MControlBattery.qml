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

        MaterialSymbol {
            anchors.verticalCenter: parent.verticalCenter
            text: Battery.available ? (Battery.isCharging ? "battery_charging_full" : "battery_full") : "battery_unknown"
            iconSize: 24
            color: root.accent
        }

        MText {
            anchors.verticalCenter: parent.verticalCenter
            visible: Battery.available
            text: `${Math.round(Battery.percentage * 100)}%`
            font.pixelSize: Looks.font.size.large
            emphasized: true
            color: root.accent
        }
    }
}
