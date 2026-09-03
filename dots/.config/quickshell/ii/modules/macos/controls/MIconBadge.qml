pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Item {
    id: root

    property color tint: Looks.colors.gray
    property string symbol: ""
    property real badgeSize: 20
    property real badgeRadius: 5

    // Every badge macOS draws sets its glyph to half the square, sidebar and pane alike.
    property real symbolSize: root.badgeSize / 2

    implicitWidth: root.badgeSize
    implicitHeight: root.badgeSize

    // Three plates offset by a pixel each: the face, a dark rim under its bottom edge and
    // a halo under that. Together they read as the drop shadow that keeps a tinted badge
    // off the accent fill of a selected row, where the tint alone is too close to it.
    Rectangle {
        y: 2
        width: parent.width
        height: parent.height
        radius: root.badgeRadius
        color: Looks.colors.badgeShadow
        antialiasing: true
    }

    Rectangle {
        y: 1
        width: parent.width
        height: parent.height
        radius: root.badgeRadius
        color: Qt.darker(root.tint, 1.45)
        antialiasing: true
    }

    Rectangle {
        anchors.fill: parent
        radius: root.badgeRadius
        antialiasing: true

        gradient: Gradient {
            GradientStop {
                position: 0
                color: root.tint
            }

            GradientStop {
                position: 1
                color: Qt.darker(root.tint, 1.06)
            }
        }
    }

    MSymbol {
        anchors.centerIn: parent
        symbol: root.symbol
        symbolSize: root.symbolSize
        color: "#ffffff"
    }
}
