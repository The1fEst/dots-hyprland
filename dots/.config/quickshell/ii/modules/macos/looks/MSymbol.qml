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

    readonly property url source: root.symbol.length === 0 ? "" : Quickshell.shellPath(`assets/sfsymbols/${root.symbol}.png`)

    // Rounded to even because every control that holds a glyph is an even number of points
    // across, and centring an odd box in an even one lands the glyph on a half pixel,
    // which the rasteriser resolves by nudging it a whole pixel to one side.
    function even(value: real): real {
        return Math.max(2, Math.round(value / 2) * 2);
    }

    implicitHeight: root.even(root.symbolSize)
    implicitWidth: root.even(root.symbolSize * (metrics.implicitWidth / Math.max(1, metrics.implicitHeight)))

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
