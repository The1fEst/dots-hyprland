pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules.common.widgets

Item {
    id: root

    required property string symbol

    property real symbolSize: 14
    property color color: Looks.colors.primary

    property real fitWidth: 0
    property real fitHeight: 0

    readonly property url source: root.symbol.length === 0 ? "" : Quickshell.shellPath(`assets/sfsymbols/${root.symbol}.png`)

    readonly property real aspect: metrics.implicitWidth / Math.max(1, metrics.implicitHeight)
    readonly property real inkHeight: root.fitWidth > 0 && root.fitHeight > 0 ? Math.min(root.fitHeight, root.fitWidth / Math.max(0.01, root.aspect)) : root.symbolSize

    readonly property size drawnPixels: Qt.size(Math.max(1, Math.round(root.width * Screen.devicePixelRatio)), Math.max(1, Math.round(root.height * Screen.devicePixelRatio)))

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

    Image {
        id: glyph
        anchors.fill: parent
        source: root.source
        sourceSize: root.drawnPixels
        smooth: true
        visible: false
        layer.enabled: true
    }

    Colorizer {
        anchors.fill: glyph
        source: glyph
        sourceColor: "black"
        colorizationColor: root.color
        opacity: root.color.a
    }
}
