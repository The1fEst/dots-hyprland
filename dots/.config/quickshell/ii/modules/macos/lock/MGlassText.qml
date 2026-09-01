pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.common.widgets
import qs.modules.macos.looks

// Text cut out of the lock's glass. The letters are never painted: their coverage is the
// shape the material takes, sharp for the silhouette and blurred for the relief.
Item {
    id: root

    required property variant backdrop
    required property variant backdropBlur

    property alias text: label.text
    property alias font: label.font
    property alias emphasized: label.emphasized
    property alias display: label.display

    // How far into the letters the field reaches: the bevel is read off it, and it is
    // also what rounds the convex corners. It has to stay proportional to the type, or
    // the same radius eats a small face's thinner strokes.
    property real spread: Math.max(1, label.font.pixelSize * 0.02)

    // The field runs three sigma past the letters and must not reach the item border,
    // which reads as an edge.
    readonly property int pad: Math.ceil(root.spread * 3)

    implicitWidth: label.implicitWidth + root.pad * 2
    implicitHeight: label.implicitHeight + root.pad * 2

    Item {
        id: mask
        anchors.fill: parent
        visible: false
        layer.enabled: true
        layer.smooth: true

        MText {
            id: label
            anchors.centerIn: parent
            color: "#ffffff"
        }
    }

    GaussianPass {
        id: fieldX
        anchors.fill: parent
        visible: false
        layer.enabled: true
        layer.smooth: true
        source: mask
        direction: Qt.vector2d(1, 0)
        sigma: root.spread * 0.8
    }

    // Coverage blurred by sigma reads back as distance with unit slope at the edge when
    // sigma is 0.8 of the range the shader maps it over.
    GaussianPass {
        id: field
        anchors.fill: parent
        visible: false
        layer.enabled: true
        layer.smooth: true
        source: fieldX
        direction: Qt.vector2d(0, 1)
        sigma: root.spread * 0.8
    }

    LiquidGlassMask {
        anchors.fill: parent
        backdrop: root.backdrop
        backdropBlur: root.backdropBlur
        shapeMask: mask
        shapeField: field
        spread: root.spread

        // The panel glass is tuned to sit dark over a bright surface. The lock is the
        // opposite: on macOS the clock reads about twice as bright as the wallpaper
        // behind it, and the panel's brightness turns the letters into a flat dark
        // silhouette instead of a frosted material.
        tint: "#59ffffff"
        brightness: 0.6

        zRadius: Looks.glass.zRadius
        refraction: Looks.glass.refraction
        chroma: Looks.glass.chroma
        edgeHighlight: Looks.glass.edgeHighlight
        specular: Looks.glass.specular
        fresnel: Looks.glass.fresnel
        distortion: Looks.glass.distortion
        saturation: Looks.glass.saturation
        bevelMode: Looks.glass.bevelMode
        glassOpacity: Looks.glass.opacity
    }
}
