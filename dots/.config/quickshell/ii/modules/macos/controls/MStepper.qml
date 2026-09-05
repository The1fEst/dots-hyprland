pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.modules.macos.looks

Item {
    id: root

    property int controlHeight: Looks.control.regular
    readonly property var metrics: Looks.control.stepperMetrics(root.controlHeight)

    property bool upAvailable: true
    property bool downAvailable: true

    signal stepped(int delta)

    implicitWidth: root.metrics.width
    implicitHeight: root.controlHeight

    ClippingRectangle {
        anchors.fill: parent
        radius: Looks.controlRadius(root.controlHeight)
        color: "transparent"
        antialiasing: true

        Column {
            anchors.fill: parent

            Half {
                delta: 1
                symbol: "chevron.up"
                available: root.upAvailable
            }

            Half {
                delta: -1
                symbol: "chevron.down"
                available: root.downAvailable
            }
        }
    }

    Rectangle {
        x: Math.round((root.width - width) / 2)
        y: root.height / 2 - height / 2
        width: root.metrics.separator
        height: 1
        radius: height / 2
        color: Looks.colors.divider
        antialiasing: true
    }

    component Half: Item {
        id: half

        required property int delta
        required property string symbol
        required property bool available

        width: root.width
        height: root.controlHeight / 2

        Rectangle {
            anchors.fill: parent
            color: {
                if (!half.available)
                    return Looks.surfaces.buttonBorderedDisabled;
                return press.pressed ? Looks.surfaces.buttonBorderedPressed : Looks.surfaces.buttonBordered;
            }
        }

        MSymbol {
            x: Math.round((half.width - width) / 2)
            y: Math.round((half.height - height) / 2)
            symbol: half.symbol
            height: Math.round(half.height / 2)
            color: half.available ? Looks.colors.primary : Looks.colors.tertiary
        }

        MouseArea {
            id: press
            anchors.fill: parent
            enabled: half.available
            cursorShape: half.available ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.stepped(half.delta)
        }
    }
}
