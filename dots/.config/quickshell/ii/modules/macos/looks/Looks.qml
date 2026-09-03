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

    // Everything below carrying a kit reference comes out of Apple's macOS 27 Sketch
    // library — the named layer styles in its document.json, which is the closest thing
    // to a machine-readable source for these. Names in comments are the style paths, so
    // a value can be re-checked against the kit without hunting for it.
    property QtObject lightColors: QtObject {
        // Kit "Content Area/Light/03 - Bordered Destructive". The rest of the system
        // palette has no named style in the kit and stays at the pre-Tahoe values.
        readonly property color red: "#ff383c"
        readonly property color orange: "#ff9500"
        readonly property color yellow: "#ffcc00"
        readonly property color green: "#28cd41"
        readonly property color mint: "#00c7be"
        readonly property color teal: "#59adc4"
        readonly property color cyan: "#55bef0"
        readonly property color blue: "#0088ff" // Kit "Content Area/Light/Controls/Active, On, 01 - Idle"
        readonly property color indigo: "#5856d6"
        readonly property color purple: "#af52de"
        readonly property color pink: "#ff2d55"
        readonly property color brown: "#a2845e"
        readonly property color gray: "#8e8e93"

        // Kit "Content Area/Light/Fills/Default". Six steps, not five — `seximal` is what
        // an inset group box is filled with, so dropping it costs the group its surface.
        readonly property color primary: "#d9000000"
        readonly property color secondary: "#80000000"
        readonly property color tertiary: "#40000000"
        readonly property color quaternary: "#1a000000"
        readonly property color quinary: "#0d000000"
        readonly property color seximal: "#08000000"

        readonly property color switchKnob: "#ffffffff"

        // Kit "Materials/Light". These are the vibrancy materials, which macOS 26 kept
        // alongside Liquid Glass rather than replacing — see `glassColors` for the latter.
        readonly property color materialUltrathin: "#61ececec"
        readonly property color materialThin: "#80ececec"
        readonly property color materialMedium: "#a1ececec"
        readonly property color materialThick: "#c2ececec"
        readonly property color materialUltrathick: "#e0ececec"

        readonly property color divider: "#0d000000" // Kit form row separator, 1px
        readonly property color menuBarHighlight: "#1a000000"
        readonly property color glassBorder: "#59ffffff"
        readonly property color glassInnerBorder: "#1a000000"
        readonly property color shadow: "#40000000"
        readonly property color hover: "#14000000"
        readonly property color pressed: "#30000000" // Kit "Controls/Active, Off, 03 - Clicked"

        // What lifts a tinted icon badge off whatever it sits on, including the accent
        // fill of a selected sidebar row, where a tint alone would not separate it.
        readonly property color badgeShadow: "#26000000"
    }

    property QtObject darkColors: QtObject {
        readonly property color red: "#ff4245" // Kit "Content Area/Dark/03 - Bordered Destructive"
        readonly property color orange: "#ff9f0a"
        readonly property color yellow: "#ffd60a"
        readonly property color green: "#32d74b"
        readonly property color mint: "#63e6e2"
        readonly property color teal: "#6ac4dc"
        readonly property color cyan: "#5ac8f5"
        readonly property color blue: "#0091ff" // Kit "Content Area/Dark/Controls/Active, On, 01 - Idle"
        readonly property color indigo: "#5e5ce6"
        readonly property color purple: "#bf5af2"
        readonly property color pink: "#ff375f"
        readonly property color brown: "#ac8e68"
        readonly property color gray: "#98989d"

        // Kit "Content Area/Dark/Fills/Selected". Primary is opaque white, not the 85%
        // the pre-Tahoe label color used.
        readonly property color primary: "#ffffffff"
        readonly property color secondary: "#8cffffff"
        readonly property color tertiary: "#40ffffff"
        readonly property color quaternary: "#1affffff"
        readonly property color quinary: "#0dffffff"
        readonly property color seximal: "#08ffffff"

        readonly property color switchKnob: "#d9ffffff"

        // Kit "Materials/Dark". The thin pair sits on a slightly cooler base than the
        // rest, which is why these are not one tint at five opacities.
        readonly property color materialUltrathin: "#66292929"
        readonly property color materialThin: "#7d292929"
        readonly property color materialMedium: "#9c2c2c2c"
        readonly property color materialThick: "#b52c2c2c"
        readonly property color materialUltrathick: "#d12c2c2c"

        readonly property color divider: "#0dffffff" // Kit form row separator, 1px
        readonly property color menuBarHighlight: "#21ffffff"
        readonly property color glassBorder: "#33ffffff"
        readonly property color glassInnerBorder: "#40000000"
        readonly property color shadow: "#66000000"
        readonly property color hover: "#1affffff"
        readonly property color pressed: "#30ffffff" // Kit "Controls/Active, Off, 03 - Clicked"
        readonly property color badgeShadow: "#26000000"
    }

    // The system accent, which is one colour across both appearances — `colors.blue` is
    // the kit's control tint and reads a shade cooler than what a switch or a sidebar
    // selection actually paints.
    readonly property color accent: "#3478f6"
    readonly property color accentPressed: dark ? Qt.lighter(accent, 1.12) : Qt.darker(accent, 1.12)

    readonly property QtObject surfaces: dark ? darkSurfaces : lightSurfaces

    // Kit "Sidebar/Background/*", "Windows/*", "Panels/*" and "Liquid Glass/*". A sidebar
    // is translucent while its window has focus and turns opaque when it loses it, which
    // is why `sidebar` and `sidebarInactive` differ in alpha as well as tint.
    property QtObject lightSurfaces: QtObject {
        readonly property color sidebar: "#ccfafafa"
        readonly property color sidebarInactive: "#fff4f4f4"
        readonly property color window: "#ffffffff"
        readonly property color panel: "#ffffffff"
        readonly property color panelBorder: "transparent"
        readonly property color inputField: "#ffffffff"

        readonly property color glassLarge: "#b3ffffff"
        readonly property color glassMedium: "#b3ffffff"
        readonly property color glassSmall: "#40000000"
        readonly property color glassSmallInactive: "#05000000"
        readonly property color glassMenu: "#8ce6e6e6"
        readonly property color glassDock: "#4d4d4d4d"
        readonly property color glassNotification: "#40bfbfbf"

        // Traffic lights carry their own reds and greens, brighter than the system
        // palette's, and drop to a flat neutral the moment the window loses focus.
        readonly property color windowClose: "#ff5c60"
        readonly property color windowMinimize: "#fac800"
        readonly property color windowExpand: "#35c759"
        readonly property color windowButtonInactive: "#26000000"

        // Kit "Content Area/Light/01 - Bordered" — the plain push button, and the fill
        // every pop-up and pull-down button starts from.
        readonly property color buttonBordered: "#14000000"
        readonly property color buttonBorderedPressed: "#29000000"

        // Opaque, not a wash: the hairline has to stay legible over whichever segment
        // fill it happens to divide, including an accent-filled selected one.
        readonly property color segmentSeparator: "#e6e6e6"
    }

    property QtObject darkSurfaces: QtObject {
        readonly property color sidebar: "#d90c0c0c"
        readonly property color sidebarInactive: "#ff292a2f"
        readonly property color window: "#ff000000"
        readonly property color panel: "#ff262628"
        readonly property color panelBorder: "#33ffffff"
        readonly property color inputField: "#22ffffff"

        readonly property color glassLarge: "#801a1a1a"
        readonly property color glassMedium: "#801a1a1a"
        readonly property color glassSmall: "#ff000000"
        readonly property color glassSmallInactive: "#0dffffff"
        readonly property color glassMenu: "#805a5a5a"
        readonly property color glassDock: "#80454545"
        readonly property color glassNotification: "#1a666666"

        // Traffic lights keep their hues across appearances; only the unfocused neutral
        // flips, since it has to read against a dark titlebar instead of a light one.
        readonly property color windowClose: "#ff5c60"
        readonly property color windowMinimize: "#fac800"
        readonly property color windowExpand: "#35c759"
        readonly property color windowButtonInactive: "#2bffffff"

        readonly property color buttonBordered: "#12ffffff"
        readonly property color buttonBorderedPressed: "#29ffffff"
        readonly property color segmentSeparator: "#262626"
    }

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
        readonly property int menuBarHeight: 34 // Kit "Menu Bar and Dock"
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
        readonly property int dockCapsuleHeight: dockPaddingTop + dockIconSize + dockIndicatorGap + dockIndicatorSize + dockIndicatorBottom

        // What the dock covers when it is out: anything laid out behind it has to stop here.
        readonly property int dockReservedHeight: dockCapsuleHeight + dockBottomMargin
        readonly property int shadowMargin: 40
    }

    // The five control sizes every macOS control is drawn at, measured off the kit's
    // switch and search-field masters, which agree on the ladder. Regular is what a
    // settings pane uses; the others exist because the sidebar icon-size preference and
    // toolbars pick different rungs.
    property QtObject control: QtObject {
        readonly property int mini: 16
        readonly property int small: 20
        readonly property int regular: 24
        readonly property int large: 28
        readonly property int extraLarge: 36

        // Kit "Toggles - Switches/*". The knob is a pill, not a circle — the switch got
        // wider in Tahoe without getting proportionally taller. Neither the track aspect
        // nor the knob inset holds across the ladder, so the rungs are listed, not derived.
        readonly property var switchLadder: ({
            "16": ({ width: 36, knobWidth: 21, knobHeight: 13 }),
            "20": ({ width: 44, knobWidth: 26, knobHeight: 16 }),
            "24": ({ width: 54, knobWidth: 32, knobHeight: 20 }),
            "28": ({ width: 64, knobWidth: 38, knobHeight: 24 }),
            "36": ({ width: 80, knobWidth: 47, knobHeight: 30 })
        })

        // Checkbox and radio share a 16pt box at regular size, with the label starting
        // 21pt in — the 5pt gap is measured from the box, not from the control bounds.
        readonly property int boxSize: 16
        readonly property int boxLabelGap: 5

        // Kit "Buttons/*/Bordered": the label sits 16 in. A pop-up button pulls its own
        // label to 12 because the trailing chevron cell already carries the balance.
        readonly property int buttonLabelInset: 16
        readonly property int popupLabelInset: 12

        // Kit "Arrow Buttons/*": the circle a borderless pop-up puts its chevron in. It
        // sits 4 further from a row edge than a push button does — bezel, not margin.
        readonly property int popupValueGap: 10
        readonly property int popupTrailingInset: 4

        function switchMetrics(height: int): var {
            return switchLadder[String(height)] ?? switchLadder["24"];
        }
        readonly property int buttonProminentLabelInset: 16
        // A segment is transparent and the container behind it carries the fill, so a
        // two-up control is one bordered box 60 wide with a hairline down the middle.
        readonly property int segmentWidth: 30
        readonly property int segmentSeparatorHeight: 20
        readonly property int segmentSeparatorRadius: 1

        // Kit "Titlebars and Toolbars/*/Medium/Buttons". A toolbar button group is a
        // capsule 24 tall on a 24 pitch, so a lone one is a circle and a back/forward
        // pair is 48 wide. It carries no separator — that is what tells it apart from a
        // segmented control, which is the same size and does.
        readonly property int toolbarButton: 24
        readonly property int toolbarButtonInset: 2

        // Kit "Titlebars and Toolbars/*/XL/Buttons": the rung a settings window sits on.
        // The group is a glass capsule with the buttons inset in it and a hairline in the
        // gap, so its width is inset + button + gap + button + inset.
        readonly property int toolbarButtonLarge: 28
        readonly property int toolbarGroupHeight: 36
        readonly property int toolbarGroupInset: 4
        readonly property int toolbarGroupGap: 9
        readonly property int toolbarSeparatorHeight: 16

        // The kit's glyph cell is 20 with the symbol drawn smaller inside it.
        readonly property int toolbarGlyphSize: 18
        readonly property int toolbarGlyphSizeLarge: 14

        // Kit "Combo Boxes": the chevron box a pop-up shows beside an inline value. Its
        // radius ladder runs half a point under the control ladder at every size.
        readonly property int chevronBoxWidth: 24
        readonly property int chevronBoxHeight: 20
        readonly property real chevronBoxRadius: 4.5
    }

    // Every rounded control in the kit lands on height/4 — the text field focus rings and
    // the stepper masks both walk 4,5,6,7,9 against heights 16,20,24,28,36. Switches and
    // search fields are the exceptions and are drawn as full pills.
    function controlRadius(height: real): real {
        return Math.max(0, height) / 4;
    }

    // Kit "Sidebars/*" and "Forms/Example Forms/*", both measured at 1x.
    property QtObject settings: QtObject {
        readonly property int sidebarWidth: 232
        readonly property int sidebarInset: 10
        readonly property int sidebarRowHeightSmall: 24
        readonly property int sidebarRowHeight: 32
        readonly property int sidebarRowHeightLarge: 40

        // Measured from the row, not the sidebar: the selection pill is the row, so the
        // icon sits this far inside it and the sidebar inset is added on top.
        readonly property int sidebarRowInset: 9
        readonly property int sidebarIconSlot: 20
        readonly property int sidebarIconRadius: 5
        readonly property int sidebarIconGap: 8

        readonly property int sidebarSelectionRadius: 8
        readonly property int sidebarSectionGap: 14
        readonly property int sidebarHeaderHeight: 18

        readonly property int sidebarTop: 12
        readonly property int sidebarSearchHeight: 28
        readonly property int sidebarSearchGlyphInset: 9
        readonly property int sidebarSearchTextGap: 8
        readonly property int sidebarUserGap: 13
        readonly property int sidebarAvatarSize: 38
        readonly property int sidebarAvatarGap: 8
        readonly property int sidebarListGap: 17

        // A form is inset from the window, and its rows inset again from the form, so a
        // label sits formInset + formRowInset from the window edge.
        readonly property int toolbarInset: 8
        readonly property int toolbarTitleGap: 12
        readonly property int paneTopGap: 16

        readonly property int formInset: 20
        readonly property int formGap: 18
        readonly property int formRadius: 12
        readonly property int formRowInset: 10
        readonly property int formRowPadding: 8

        // The floor for a row; anything with a detail line under the label grows past it.
        readonly property int formRowHeight: 40
        readonly property int formRowLabelGap: 2
        readonly property int formRowIconSize: 26
        readonly property int formRowIconRadius: 6
        readonly property int formRowIconGap: 12

        // A list of choices reserves the tick column on every row, so the unticked ones
        // line up with the ticked one instead of sliding left.
        readonly property int formRowTickSlot: 32
        readonly property int formRowDotSize: 8

        // A glyph acting as a control carries its own bezel, so a row trailing one stops
        // further from the edge than one trailing a push button.
        readonly property int formRowControlInset: 22

        readonly property int sheetWidth: 400
        readonly property int sheetPadding: 20
        readonly property int sheetFooterGap: 21
        readonly property int sheetFooterHeight: 63
        readonly property int sheetButtonWidth: 64
    }

    // Per-component metrics off the kit's remaining pages. Grouped rather than flattened
    // into `sizes` because these are each one component's contract, not shared scale.
    property QtObject metrics: QtObject {
        readonly property QtObject menu: QtObject {
            readonly property int rowHeightSmall: 19
            readonly property int rowHeight: 22
            readonly property int rowHeightLarge: 24
            readonly property int highlightRadius: 8
            readonly property int separatorHeight: 1

            // Each modifier in a shortcut cluster occupies a fixed cell, so ⌘⇧A and ⌥A
            // line their letters up down the right edge of the menu.
            readonly property int shortcutGlyphWidth: 12
            readonly property int shortcutGlyphHeight: 16
        }

        readonly property QtObject popover: QtObject {
            readonly property int radius: 20
        }

        readonly property QtObject tooltip: QtObject {
            readonly property int height: 19
        }

        readonly property QtObject alert: QtObject {
            readonly property int width: 260
            readonly property int widthWide: 300
            readonly property int buttonRowHeight: 28
        }

        readonly property QtObject notification: QtObject {
            readonly property int width: 344
            readonly property int height: 78
            readonly property int imageSize: 32
            readonly property int imageRadius: 6
        }

        readonly property QtObject slider: QtObject {
            // A plain slider rides a 4pt track; adding tick marks thickens it to 6 so the
            // ticks below it still read as subordinate.
            readonly property int trackHeight: 4
            readonly property int trackHeightTicked: 6
            readonly property int tickHeight: 4
        }

        readonly property QtObject scrollbar: QtObject {
            readonly property int width: 12
            readonly property int knobWidth: 6
            readonly property int knobRadius: 3
        }

        readonly property QtObject progress: QtObject {
            readonly property int barHeight: 6
            readonly property int barHeightLarge: 10
            readonly property int spinnerSize: 16
            readonly property int spinnerSizeLarge: 32
        }

        readonly property QtObject titlebar: QtObject {
            readonly property int height: 52

            // Traffic lights: three 14pt dots on a 23pt pitch, so 68 across. A utility
            // panel shrinks them to 10 on a 17pt pitch instead of scaling the cluster.
            readonly property int buttonSize: 14
            readonly property int buttonPitch: 23
            readonly property int buttonsWidth: 68
            readonly property int panelButtonSize: 10
            readonly property int panelButtonPitch: 17
        }

        // The bar's own height lives in `sizes.menuBarHeight`, which the panel and its
        // exclusive zone already read.
        readonly property QtObject menuBar: QtObject {
            readonly property int itemHeight: 24
            readonly property int selectionHeight: 25
            readonly property int selectionRadius: 13
        }
    }

    property QtObject font: QtObject {
        // One variable family for both. SF Pro carries dynamic optical sizes now, so it
        // interpolates the letterform for the point size on its own; the separate Text
        // and Display cuts are the pre-variable fallback and the kit no longer uses them.
        readonly property string display: "SF Pro"
        readonly property string text: "SF Pro"
        readonly property string mono: "SF Mono"

        readonly property QtObject size: QtObject {
            readonly property int tiny: 10
            readonly property int small: 11
            readonly property int normal: 13
            readonly property int medium: 14
            readonly property int large: 15
            readonly property int title: 20
        }

        // The macOS built-in text styles. `emphasizedStyleName` is what the bold trait
        // resolves to for that style, which is not a uniform step up — Headline goes to
        // Heavy and Caption 1 only to Medium — so picking a face by hand drifts off it.
        //
        // `tight` and `loose` are the leading traits: tight for a list row where height is
        // scarce, loose for a passage read across many lines. Below three lines, avoid
        // tight even where it fits.
        //
        // SF Pro is variable, so a face is selected by name through font.styleName. Going
        // through font.weight instead makes Qt synthesise from the default instance and
        // the result is not the cut Apple drew, which is why these are style names.
        readonly property QtObject style: QtObject {
            readonly property var largeTitle: ({ size: 26, lineHeight: 32, tight: 30, loose: 34, styleName: "Regular", emphasizedStyleName: "Bold" })
            readonly property var title1: ({ size: 22, lineHeight: 26, tight: 24, loose: 28, styleName: "Regular", emphasizedStyleName: "Bold" })
            readonly property var title2: ({ size: 17, lineHeight: 22, tight: 20, loose: 24, styleName: "Regular", emphasizedStyleName: "Bold" })
            readonly property var title3: ({ size: 15, lineHeight: 20, tight: 18, loose: 22, styleName: "Regular", emphasizedStyleName: "Semibold" })
            readonly property var headline: ({ size: 13, lineHeight: 16, tight: 14, loose: 18, styleName: "Bold", emphasizedStyleName: "Heavy" })
            readonly property var body: ({ size: 13, lineHeight: 16, tight: 14, loose: 18, styleName: "Regular", emphasizedStyleName: "Semibold" })
            readonly property var callout: ({ size: 12, lineHeight: 15, tight: 13, loose: 17, styleName: "Regular", emphasizedStyleName: "Semibold" })
            readonly property var subheadline: ({ size: 11, lineHeight: 14, tight: 12, loose: 16, styleName: "Regular", emphasizedStyleName: "Semibold" })
            readonly property var footnote: ({ size: 10, lineHeight: 13, tight: 11, loose: 15, styleName: "Regular", emphasizedStyleName: "Semibold" })
            readonly property var caption1: ({ size: 10, lineHeight: 13, tight: 11, loose: 15, styleName: "Regular", emphasizedStyleName: "Medium" })
            readonly property var caption2: ({ size: 10, lineHeight: 13, tight: 11, loose: 15, styleName: "Medium", emphasizedStyleName: "Semibold" })
        }

        // Controls label themselves in Medium, not the Regular that body copy uses — every
        // button, checkbox, menu item and field placeholder in the kit is set this way.
        readonly property string controlStyleName: "Medium"

        readonly property list<string> weights: ["Ultralight", "Thin", "Light", "Regular", "Medium", "Semibold", "Bold", "Heavy", "Black"]

        // macOS darkens stems as it rasterises, so the cut the kit names comes out about a
        // fifth heavier there than Qt draws it. Measured against the settings pane: label
        // ink per point 3.29 on macOS against 2.69 here, and the same ratio at every
        // weight. One rung up the family closes it, so every style is asked for through
        // this rather than by the name the kit states.
        function rendered(styleName: string): string {
            const at = weights.indexOf(styleName);
            return at < 0 ? styleName : weights[Math.min(weights.length - 1, at + 1)];
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
