import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

LazyLoader {
    id: root

    property Item anchorItem
    readonly property bool onFocusedMonitor: (root.QsWindow?.window?.screen?.name ?? "") === (Hyprland.focusedMonitor?.name ?? "")
    readonly property bool anchorReady: (root.QsWindow?.window ?? null) !== null && (root.anchorItem?.width ?? 0) > 0
    readonly property bool shown: GlobalStates.calendarOpen && root.onFocusedMonitor

    active: root.shown || Config.options.sidebar.keepRightSidebarLoaded

    component: PanelWindow {
        id: popupWindow
        visible: root.shown
        color: "transparent"

        function hide(): void {
            GlobalStates.calendarOpen = false;
        }

        anchors.left: !Config.options.bar.vertical || (Config.options.bar.vertical && !Config.options.bar.bottom)
        anchors.right: Config.options.bar.vertical && Config.options.bar.bottom
        anchors.top: Config.options.bar.vertical || (!Config.options.bar.vertical && !Config.options.bar.bottom)
        anchors.bottom: !Config.options.bar.vertical && Config.options.bar.bottom

        implicitWidth: popupBackground.implicitWidth + Appearance.sizes.elevationMargin * 2
        implicitHeight: popupBackground.implicitHeight + Appearance.sizes.elevationMargin * 2

        mask: Region {
            item: popupBackground
        }

        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0

        property real anchorLeft: 0
        property real anchorTop: 0

        function reposition(): void {
            if (!root.anchorReady)
                return;
            const origin = root.QsWindow.mapFromItem(root.anchorItem,
                (root.anchorItem.width - popupBackground.implicitWidth) / 2,
                (root.anchorItem.height - popupBackground.implicitHeight) / 2);
            popupWindow.anchorLeft = origin.x;
            popupWindow.anchorTop = origin.y;
        }

        margins {
            left: Config.options.bar.vertical ? Appearance.sizes.verticalBarWidth : popupWindow.anchorLeft
            top: Config.options.bar.vertical ? popupWindow.anchorTop : Appearance.sizes.barHeight
            right: Appearance.sizes.verticalBarWidth
            bottom: Appearance.sizes.barHeight
        }
        WlrLayershell.namespace: "quickshell:calendarPanel"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        onVisibleChanged: {
            if (popupWindow.visible) {
                popupWindow.reposition();
                GlobalFocusGrab.addDismissable(popupWindow);
            } else {
                GlobalFocusGrab.removeDismissable(popupWindow);
            }
        }
        Component.onCompleted: {
            if (!popupWindow.visible)
                return;
            popupWindow.reposition();
            GlobalFocusGrab.addDismissable(popupWindow);
        }
        Component.onDestruction: GlobalFocusGrab.removeDismissable(popupWindow)
        Connections {
            target: GlobalFocusGrab
            function onDismissed() {
                popupWindow.hide();
            }
        }

        StyledRectangularShadow {
            target: popupBackground
        }

        Rectangle {
            id: popupBackground
            anchors {
                fill: parent
                margins: Appearance.sizes.elevationMargin
            }
            implicitWidth: 420
            implicitHeight: 350
            color: Appearance.colors.colLayer0
            radius: Appearance.rounding.normal
            border.width: 1
            border.color: Appearance.colors.colLayer0Border

            CalendarPanelContent {
                anchors.fill: parent
                anchors.margins: 10
                focus: true

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        popupWindow.hide();
                    }
                }
            }
        }
    }
}
