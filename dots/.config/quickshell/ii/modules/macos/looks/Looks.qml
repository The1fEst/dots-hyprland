pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules.common
import qs.modules.common.functions

Singleton {
    id: root

    readonly property bool dark: Appearance.m3colors.darkmode
    readonly property QtObject colors: dark ? darkColors : lightColors

    property QtObject lightColors: QtObject {
        readonly property color red: "#ff3b30"
        readonly property color orange: "#ff9500"
        readonly property color yellow: "#ffcc00"
        readonly property color green: "#28cd41"
        readonly property color mint: "#00c7be"
        readonly property color teal: "#59adc4"
        readonly property color cyan: "#55bef0"
        readonly property color blue: "#007aff"
        readonly property color indigo: "#5856d6"
        readonly property color purple: "#af52de"
        readonly property color pink: "#ff2d55"
        readonly property color brown: "#a2845e"
        readonly property color gray: "#8e8e93"

        readonly property color primary: "#d9000000"
        readonly property color secondary: "#80000000"
        readonly property color tertiary: "#40000000"
        readonly property color quaternary: "#1a000000"
        readonly property color quinary: "#0d000000"

        readonly property color materialUltrathin: "#5cf6f6f6"
        readonly property color materialThin: "#7af6f6f6"
        readonly property color materialMedium: "#99f6f6f6"
        readonly property color materialThick: "#b8f6f6f6"
        readonly property color materialUltrathick: "#d6f6f6f6"

        readonly property color divider: "#26000000"
        readonly property color menuBarHighlight: "#1a000000"
        readonly property color glassBorder: "#59ffffff"
        readonly property color glassInnerBorder: "#1a000000"
        readonly property color shadow: "#40000000"
        readonly property color hover: "#14000000"
        readonly property color pressed: "#26000000"
    }

    property QtObject darkColors: QtObject {
        readonly property color red: "#ff453a"
        readonly property color orange: "#ff9f0a"
        readonly property color yellow: "#ffd60a"
        readonly property color green: "#32d74b"
        readonly property color mint: "#63e6e2"
        readonly property color teal: "#6ac4dc"
        readonly property color cyan: "#5ac8f5"
        readonly property color blue: "#0a84ff"
        readonly property color indigo: "#5e5ce6"
        readonly property color purple: "#bf5af2"
        readonly property color pink: "#ff375f"
        readonly property color brown: "#ac8e68"
        readonly property color gray: "#98989d"

        readonly property color primary: "#d9ffffff"
        readonly property color secondary: "#8cffffff"
        readonly property color tertiary: "#40ffffff"
        readonly property color quaternary: "#1affffff"
        readonly property color quinary: "#0dffffff"

        readonly property color materialUltrathin: "#66282828"
        readonly property color materialThin: "#80282828"
        readonly property color materialMedium: "#99282828"
        readonly property color materialThick: "#b3282828"
        readonly property color materialUltrathick: "#cc282828"

        readonly property color divider: "#1affffff"
        readonly property color menuBarHighlight: "#21ffffff"
        readonly property color glassBorder: "#33ffffff"
        readonly property color glassInnerBorder: "#40000000"
        readonly property color shadow: "#66000000"
        readonly property color hover: "#1affffff"
        readonly property color pressed: "#33ffffff"
    }

    readonly property color accent: colors.blue

    property QtObject radius: QtObject {
        readonly property int tiny: 4
        readonly property int small: 6
        readonly property int normal: 10
        readonly property int large: 16
        readonly property int base: 50
        readonly property real scale: -0.00115
        readonly property real shortSideFactor: 0.4
        readonly property int maximum: 55
        readonly property int huge: 26
        readonly property int window: 12
    }

    function radiusFor(width: real, height: real): real {
        const w = Math.max(1, width);
        const h = Math.max(1, height);
        const shortSide = Math.min(w, h);
        const grown = Math.max(radius.base + radius.scale * w * h, radius.shortSideFactor * shortSide);
        return Math.max(0, Math.min(grown, radius.maximum, shortSide / 2));
    }

    property QtObject sizes: QtObject {
        readonly property int menuBarHeight: 36
        readonly property int menuBarItemInset: 6
        readonly property int menuBarItemMinWidth: 48
        readonly property int menuBarItemSpacing: 0
        readonly property var dockSettings: Config.options?.macos.dock ?? null
        readonly property int dockIconSize: dockSettings?.iconSize ?? 57
        readonly property int dockIconMaxSize: dockIconSize + 27
        readonly property int dockIconSpacing: dockSettings?.iconSpacing ?? 17
        readonly property int dockIconRadius: dockSettings?.iconRadius ?? 13
        readonly property int dockSeparatorWidth: dockIconSpacing
        readonly property int dockPaddingH: dockSettings?.paddingH ?? 16
        readonly property int dockPaddingTop: dockSettings?.paddingTop ?? 16
        readonly property int dockSeparatorInset: 12
        readonly property int dockIndicatorGap: 9
        readonly property int dockIndicatorSize: 4
        readonly property int dockIndicatorBottom: 4
        readonly property int dockBottomMargin: dockSettings?.bottomMargin ?? 6
        readonly property int shadowMargin: 40
    }

    property QtObject font: QtObject {
        readonly property string display: "SF Pro Display"
        readonly property string text: "SF Pro Text"
        readonly property string mono: "SF Mono"

        readonly property QtObject size: QtObject {
            readonly property int tiny: 10
            readonly property int small: 11
            readonly property int normal: 13
            readonly property int medium: 14
            readonly property int large: 15
            readonly property int title: 20
        }
    }

    property QtObject glass: QtObject {
        readonly property var settings: Config.options?.macos.glass ?? null

        readonly property color base: root.dark ? "#ffffff" : "#f6f6f6"
        readonly property color tint: ColorUtils.applyAlpha(base, settings?.tintOpacity ?? 0)
        readonly property real cornerPower: 4
        readonly property real blur: 1.0
        readonly property real blurMax: settings?.blur ?? 50
        readonly property real zRadius: settings?.zRadius ?? 2.6
        readonly property real refraction: settings?.refraction ?? 1
        readonly property real chroma: settings?.chroma ?? 0
        readonly property real edgeHighlight: settings?.edgeHighlight ?? 0
        readonly property real specular: settings?.specular ?? 0.2
        readonly property real fresnel: settings?.fresnel ?? 0
        readonly property real distortion: settings?.distortion ?? 0
        readonly property real saturation: settings?.saturation ?? 0
        readonly property real brightness: settings?.brightness ?? 0
        readonly property real bevelMode: settings?.bevelMode ?? 0
        readonly property real opacity: settings?.opacity ?? 1
        readonly property real shadowSpread: settings?.shadowSpread ?? 10
        readonly property real shadowOffset: 4
        readonly property color shadowColor: ColorUtils.applyAlpha("#000000", settings?.shadowOpacity ?? 0.3)
    }

    property QtObject animation: QtObject {
        readonly property int fast: 150
        readonly property int normal: 250
        readonly property int slow: 400
        readonly property list<real> standard: [0.25, 0.1, 0.25, 1, 1, 1]
        readonly property list<real> spring: [0.34, 1.36, 0.44, 1, 1, 1]
    }
}
