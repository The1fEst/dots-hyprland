pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    required property var keyData

    readonly property string label: root.keyData.label ?? ""
    readonly property string keytype: root.keyData.keytype ?? "normal"
    readonly property var keycode: root.keyData.keycode
    readonly property string shape: root.keyData.shape ?? "normal"
    readonly property bool isShift: Ydotool.shiftKeys.includes(root.keycode)
    readonly property bool isBackspace: root.label.toLowerCase() === "backspace"
    readonly property bool isEnter: root.label.toLowerCase() === "enter" || root.label.toLowerCase() === "return"
    property bool held: false
    readonly property bool lit: root.isShift ? Ydotool.shiftMode > 0 : (root.held || pressArea.pressed)

    readonly property real unitWidth: 44
    readonly property real unitHeight: 42
    readonly property var widthMultiplier: ({
            normal: 1,
            fn: 1,
            tab: 1.6,
            caps: 1.9,
            shift: 2.5,
            control: 1.3
        })
    readonly property var heightMultiplier: ({
            normal: 1,
            fn: 0.7,
            tab: 1,
            caps: 1,
            shift: 1,
            control: 1
        })

    implicitWidth: root.unitWidth * (root.widthMultiplier[root.shape] ?? 1)
    implicitHeight: root.unitHeight * (root.heightMultiplier[root.shape] ?? 1)
    Layout.fillWidth: root.shape === "space" || root.shape === "expand"
    visible: root.shape !== "empty"
    // Keys keep a key's shape rather than the size-derived radius, which at this size
    // would round them into circles.
    radius: Looks.radius.normal
    tint: root.lit ? Looks.accent : Looks.glass.tint

    // Shift taps in a row escalate to caps lock, the way a physical double tap does.
    Timer {
        id: capsTimer
        property bool started: false
        property bool canCaps: false
        interval: 300
        function begin(): void {
            capsTimer.started = true;
            capsTimer.canCaps = true;
            capsTimer.start();
        }
        onTriggered: capsTimer.canCaps = false
    }

    Connections {
        target: Ydotool
        enabled: root.isShift

        function onShiftModeChanged() {
            if (Ydotool.shiftMode === 0)
                capsTimer.started = false;
        }
    }

    MText {
        anchors.centerIn: parent
        visible: !root.isBackspace && !root.isEnter
        text: Ydotool.shiftMode === 2 ? (root.keyData.labelCaps ?? root.keyData.labelShift ?? root.label) : Ydotool.shiftMode === 1 ? (root.keyData.labelShift ?? root.label) : root.label
        font.pixelSize: root.shape === "fn" ? Looks.font.size.small : Looks.font.size.large
        color: root.lit ? "#ffffff" : Looks.colors.primary
    }

    MaterialSymbol {
        anchors.centerIn: parent
        visible: root.isBackspace || root.isEnter
        text: root.isBackspace ? "backspace" : "keyboard_return"
        iconSize: 20
        color: root.lit ? "#ffffff" : Looks.colors.primary
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: {
            Ydotool.press(root.keycode);
            if (root.isShift && Ydotool.shiftMode === 0)
                Ydotool.shiftMode = 1;
        }

        onReleased: {
            if (root.keytype === "normal") {
                Ydotool.release(root.keycode);
                if (Ydotool.shiftMode === 1)
                    Ydotool.releaseShiftKeys();
                return;
            }
            if (root.isShift) {
                if (Ydotool.shiftMode === 1) {
                    if (!capsTimer.started) {
                        capsTimer.begin();
                    } else if (capsTimer.canCaps) {
                        Ydotool.shiftMode = 2;
                    } else {
                        Ydotool.releaseShiftKeys();
                    }
                } else if (Ydotool.shiftMode === 2) {
                    Ydotool.releaseShiftKeys();
                }
                return;
            }
            if (root.keytype === "modkey") {
                root.held = !root.held;
                if (!root.held)
                    Ydotool.release(root.keycode);
            }
        }
    }
}
