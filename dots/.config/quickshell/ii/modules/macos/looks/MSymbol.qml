pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.common.widgets

Item {
    id: root

    required property string symbol

    property color color: Looks.colors.primary

    readonly property real pixelRatio: Screen.devicePixelRatio

    implicitWidth: Math.round(root.height * MSymbolArt.aspectOf(root.symbol))

    readonly property var fit: MSymbolArt.largestFitting(root.symbol, root.width * root.pixelRatio, root.height * root.pixelRatio)
    readonly property url source: MSymbolArt.artFor(root.symbol, root.width * root.pixelRatio, root.height * root.pixelRatio)

    readonly property real artWidth: (root.fit?.[0] ?? 1) / root.pixelRatio
    readonly property real artHeight: (root.fit?.[1] ?? 1) / root.pixelRatio

    readonly property real shrinkToFit: Math.min(1, root.height / root.artHeight, root.width / root.artWidth)

    function centred(box: real, ink: real): real {
        return Math.floor((box - ink) / 2);
    }

    Image {
        id: glyph

        x: root.centred(root.width, width)
        y: root.centred(root.height, height)
        width: root.artWidth * root.shrinkToFit
        height: root.artHeight * root.shrinkToFit
        source: root.source
        sourceSize: Qt.size(root.fit?.[0] ?? 1, root.fit?.[1] ?? 1)
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
