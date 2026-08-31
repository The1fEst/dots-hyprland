pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import qs.modules.common.widgets

Item {
    id: root

    required property MGlassBackdrop backdrop
    property real radius: Looks.radius.large
    property color tint: Looks.glass.tint

    default property alias content: contentItem.data

    readonly property RectangularShadow shadowLayer: RectangularShadow {
        parent: root
        anchors.fill: parent
        radius: root.radius
        blur: Looks.glass.shadowSpread
        spread: 0
        offset: Qt.vector2d(0, Looks.glass.shadowOffset)
        color: Looks.glass.shadowColor
        cached: true
    }

    readonly property LiquidGlass glassLayer: LiquidGlass {
        parent: root
        anchors.fill: parent
        backdrop: root.backdrop.sharp
        backdropBlur: root.backdrop.blurred
        radius: root.radius
        tint: root.tint
        zRadius: Looks.glass.zRadius
        refraction: Looks.glass.refraction
        chroma: Looks.glass.chroma
        edgeHighlight: Looks.glass.edgeHighlight
        specular: Looks.glass.specular
        fresnel: Looks.glass.fresnel
        distortion: Looks.glass.distortion
        saturation: Looks.glass.saturation
        brightness: Looks.glass.brightness
        bevelMode: Looks.glass.bevelMode
        glassOpacity: Looks.glass.opacity
        cornerPower: {
            const limit = Math.max(1, Math.min(root.width, root.height) / 2);
            const t = Math.max(0, Math.min(1, (root.radius / limit - 0.7) / 0.3));
            return Looks.glass.cornerPower + (2 - Looks.glass.cornerPower) * t;
        }
    }

    readonly property Item contentLayer: Item {
        id: contentItem
        parent: root
        anchors.fill: parent
    }
}
