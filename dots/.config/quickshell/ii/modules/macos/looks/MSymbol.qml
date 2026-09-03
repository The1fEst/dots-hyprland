pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import org.kde.kirigami as Kirigami

// The one place an SF Symbol is drawn. Everything that shows a glyph goes through here, so
// the sizing rule below only has to hold in one file.
Item {
    id: root

    required property string symbol

    // The glyph's ink height in points, which is how the kit specifies every symbol.
    property real symbolSize: 14
    property color color: Looks.colors.primary

    property real fitWidth: 0
    property real fitHeight: 0

    readonly property real aspect: metrics.implicitWidth / Math.max(1, metrics.implicitHeight)
    readonly property real inkHeight: root.fitWidth > 0 && root.fitHeight > 0 ? Math.min(root.fitHeight, root.fitWidth / Math.max(0.01, root.aspect)) : root.symbolSize

    readonly property url source: root.symbol.length === 0 ? "" : Quickshell.shellPath(`assets/sfsymbols/${root.symbol}.png`)

    function roundedToEven(value: real): real {
        return Math.max(2, Math.round(value / 2) * 2);
    }

    implicitHeight: root.roundedToEven(root.inkHeight)
    implicitWidth: root.roundedToEven(root.inkHeight * root.aspect)

    Image {
        id: metrics
        width: 0
        height: 0
        source: root.source
        asynchronous: false
    }

    Kirigami.Icon {
        anchors.fill: parent
        source: root.source
        color: root.color
        isMask: true
        roundToIconSize: false
        smooth: true
    }
}
