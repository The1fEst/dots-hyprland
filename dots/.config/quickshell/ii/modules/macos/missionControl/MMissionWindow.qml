pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.modules.macos.looks

// One window, live, at wherever the layout put it.
ClippingRectangle {
    id: root

    required property var toplevel

    // The window's own size. The capture is taken at it and minified through mipmaps:
    // drawing a full-resolution buffer straight into a thumbnail-sized rect samples one
    // texel per pixel and tears the content apart.
    required property real sourceWidth
    required property real sourceHeight

    property bool interactive: true

    signal activated

    color: "transparent"
    radius: Math.min(Looks.radius.window, Math.min(root.width, root.height) / 4)
    antialiasing: true

    ScreencopyView {
        id: capture
        visible: false
        width: Math.max(1, root.sourceWidth)
        height: Math.max(1, root.sourceHeight)
        captureSource: GlobalStates.missionControlOpen ? root.toplevel : null
        live: true
        paintCursor: false
    }

    ShaderEffectSource {
        anchors.fill: parent
        sourceItem: capture
        hideSource: true
        live: true
        mipmap: true
        smooth: true
    }

    Rectangle {
        anchors.fill: parent
        visible: root.interactive
        color: "transparent"
        border.width: hover.containsMouse ? 3 : 1
        border.color: hover.containsMouse ? Looks.accent : Looks.colors.glassBorder
        radius: root.radius
        antialiasing: true
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
