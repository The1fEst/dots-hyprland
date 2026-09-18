import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    ContentSection {
        icon: "visibility"
        title: Translation.tr("Seeing")

        OptionSpinBox {
            icon: "height"
            text: Translation.tr("Cursor size")
            current: DesktopAppearance.cursorSize
            from: 8
            to: 128
            stepSize: 4
            onCommitted: size => DesktopAppearance.setCursor(DesktopAppearance.cursorTheme, size)
        }

        ContentSubsection {
            title: Translation.tr("Screen zoom")
            tooltip: Translation.tr("The whole screen, magnified around the pointer. 100% is no magnification.")

            OptionSpinBox {
                icon: "zoom_in"
                text: Translation.tr("Magnification (%)")
                current: Math.round(HyprlandOptions.number("cursor:zoom_factor") * 100)
                from: 100
                to: 500
                stepSize: 10
                onCommitted: zoom => HyprlandOptions.set("cursor:zoom_factor", zoom / 100)
            }

            HyprlandSwitch {
                buttonIcon: "grid_on"
                text: Translation.tr("Keep the magnified image sharp")
                option: "cursor:zoom_rigid"
            }
        }
    }

    ContentSection {
        icon: "animation"
        title: Translation.tr("Motion")

        HyprlandSwitch {
            buttonIcon: "animation"
            text: Translation.tr("Animations")
            option: "animations:enabled"

            StyledToolTip {
                text: Translation.tr("Turning animations off makes windows and workspaces appear at once instead of moving.")
            }
        }

        HyprlandSwitch {
            buttonIcon: "open_with"
            text: Translation.tr("Animate manual resizes")
            option: "misc:animate_manual_resizes"
        }

        HyprlandSwitch {
            buttonIcon: "drag_pan"
            text: Translation.tr("Animate windows being dragged")
            option: "misc:animate_mouse_windowdragging"
        }
    }

    ContentSection {
        icon: "keyboard"
        title: Translation.tr("Typing")

        ContentLinkRow {
            buttonIcon: "keyboard"
            title: Translation.tr("Key repeat")
            subtitle: Translation.tr("How long a held key waits and how fast it repeats")
            onClicked: root.subpageRequested(title, "modules/settings/KeyboardConfig.qml")
        }
    }
}
