pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.common.widgets

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: panelRoot
        required property var modelData

        screen: modelData
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell:background"
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        StyledImage {
            anchors.fill: parent
            source: Config.options.background.wallpaperPath
            fillMode: Image.PreserveAspectCrop
            cache: true
        }
    }
}
