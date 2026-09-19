pragma ComponentBehavior: Bound
import qs
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.synchronizer
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

// Options toolbar
Toolbar {
    id: root

    property var captureMode
    property bool optionsOpen: false

    signal dismiss()

    readonly property var modes: [
        {
            icon: "fullscreen",
            name: Translation.tr("Whole screen")
        },
        {
            icon: "select_window",
            name: Translation.tr("A window")
        },
        {
            icon: "activity_zone",
            name: Translation.tr("A region")
        },
        {
            icon: "gesture",
            name: Translation.tr("A drawn shape")
        },
        {
            icon: "screen_record",
            name: Translation.tr("Record the screen")
        },
        {
            icon: "screenshot_region",
            name: Translation.tr("Record a region")
        }
    ]

    ToolbarTabBar {
        id: modeBar
        tabButtonList: root.modes

        delegate: ToolbarTabButton {
            required property int index
            required property var modelData
            current: index === modeBar.currentIndex
            text: ""
            materialSymbol: modelData.icon
            onClicked: modeBar.setCurrentIndex(index)

            StyledToolTip {
                text: modelData.name
            }
        }

        Synchronizer on currentIndex {
            property alias source: root.captureMode
        }
    }

    Rectangle {
        Layout.fillHeight: true
        Layout.topMargin: 6
        Layout.bottomMargin: 6
        Layout.leftMargin: 2
        Layout.rightMargin: 2
        implicitWidth: 1
        color: Appearance.colors.colOutlineVariant
    }

    ToolbarButton {
        id: optionsButton
        horizontalPadding: 10
        implicitWidth: implicitContentWidth + horizontalPadding * 2
        colBackground: ColorUtils.transparentize(Appearance.colors.colSurfaceContainer)
        colBackgroundHover: ColorUtils.transparentize(Appearance.colors.colOnSurface, root.optionsOpen ? 1 : 0.95)
        colRipple: ColorUtils.transparentize(Appearance.colors.colOnSurface, 0.95)
        onClicked: root.optionsOpen = !root.optionsOpen

        contentItem: Row {
            anchors.centerIn: parent
            spacing: 6

            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                iconSize: 22
                text: "tune"
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: Translation.tr("Options")
            }
            MaterialSymbol {
                anchors.verticalCenter: parent.verticalCenter
                iconSize: 20
                text: root.optionsOpen ? "keyboard_arrow_down" : "keyboard_arrow_up"
            }
        }
    }
}
