pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    property real glassWidth: Math.min(260, width * 0.45)
    property real glassHeight: 96
    property real glassRadius: Looks.radius.dock

    Layout.fillWidth: true
    implicitHeight: 220

    component Backdrop: StyledImage {
        anchors.fill: parent
        source: Config.options.background.wallpaperPath
        fillMode: Image.PreserveAspectCrop
        cache: true
    }

    Backdrop {}

    Item {
        id: composite
        anchors.fill: parent
        visible: false
        Backdrop {}
    }

    ShaderEffectSource {
        id: sharpSource
        visible: false
        sourceItem: composite
        live: true
        width: root.width
        height: root.height
    }

    Item {
        id: blurLayer
        anchors.fill: parent
        visible: false
        layer.enabled: true

        MultiEffect {
            source: sharpSource
            anchors.fill: parent
            blurEnabled: true
            blurMax: Looks.glass.blurMax
            blur: Looks.glass.blur
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        drag.target: glass
        drag.minimumX: 0
        drag.maximumX: root.width - glass.width
        drag.minimumY: 0
        drag.maximumY: root.height - glass.height
        cursorShape: Qt.OpenHandCursor
    }

    LiquidGlass {
        id: glass

        x: (root.width - width) / 2
        y: (root.height - height) / 2
        width: root.glassWidth
        height: root.glassHeight

        backdrop: sharpSource
        backdropBlur: blurLayer
        radius: root.glassRadius
        tint: Looks.glass.tint
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
        cornerPower: Looks.glass.cornerPower

        MText {
            anchors.centerIn: parent
            text: "Glass"
            emphasized: true
            color: "#ffffff"
        }
    }
}
