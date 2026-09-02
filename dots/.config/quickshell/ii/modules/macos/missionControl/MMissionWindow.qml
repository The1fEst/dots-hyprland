pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.modules.macos.looks

// One window, live, at wherever the layout put it. The visual is a child rather than the
// root so a drag can move it without breaking the position the layout binds.
Item {
    id: root

    required property var toplevel
    required property string address

    // The window's own size. The capture is taken at it and minified through mipmaps:
    // drawing a full-resolution buffer straight into a thumbnail-sized rect samples one
    // texel per pixel and tears the content apart.
    required property real sourceWidth
    required property real sourceHeight

    property bool interactive: true

    // What a dragged window shrinks to, so it stops covering the strip it is aimed at.
    property real dragHeight: 160

    signal activated

    z: dragArea.drag.active ? 1 : 0

    ClippingRectangle {
        id: visual

        // Shrunk about the grab point, so the pixel under the cursor stays under it and
        // the drop target the hotspot reports keeps following the cursor.
        property real shrink: dragArea.drag.active ? Math.min(1, root.dragHeight / Math.max(1, root.height)) : 1

        transform: Scale {
            origin.x: dragArea.grabX
            origin.y: dragArea.grabY
            xScale: visual.shrink
            yScale: visual.shrink
        }

        Behavior on shrink {
            NumberAnimation {
                duration: Looks.animation.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Looks.animation.standard
            }
        }

        width: root.width
        height: root.height
        color: "transparent"
        radius: Math.min(Looks.radius.window, Math.min(visual.width, visual.height) / 4)
        antialiasing: true

        Drag.active: dragArea.drag.active
        Drag.source: root

        // The grab point, not the centre: a window preview is large, and the desktop you
        // drop onto is the one under the cursor.
        Drag.hotSpot.x: dragArea.grabX
        Drag.hotSpot.y: dragArea.grabY
        Drag.keys: ["macosMissionWindow"]

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
            border.width: dragArea.containsMouse ? 3 : 1
            border.color: dragArea.containsMouse ? Looks.accent : Looks.colors.glassBorder
            radius: visual.radius
            antialiasing: true
        }

        MouseArea {
            id: dragArea

            property real grabX: visual.width / 2
            property real grabY: visual.height / 2

            anchors.fill: parent
            enabled: root.interactive
            hoverEnabled: true
            cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
            drag.target: root.interactive ? visual : null
            drag.smoothed: false

            onPressed: event => {
                dragArea.grabX = event.x;
                dragArea.grabY = event.y;
            }

            onClicked: {
                if (!drag.active)
                    root.activated();
            }

            onReleased: {
                if (visual.Drag.drop() !== Qt.IgnoreAction)
                    return;
                // Refused, so the window belongs back where the layout put it.
                returnHome.restart();
            }
        }

        ParallelAnimation {
            id: returnHome

            NumberAnimation {
                target: visual
                property: "x"
                to: 0
                duration: Looks.animation.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Looks.animation.standard
            }

            NumberAnimation {
                target: visual
                property: "y"
                to: 0
                duration: Looks.animation.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Looks.animation.standard
            }
        }
    }
}
