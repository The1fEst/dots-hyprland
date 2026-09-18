import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    ContentSection {
        icon: "select_window_2"
        title: Translation.tr("Workspaces")

        HyprlandSwitch {
            buttonIcon: "history"
            text: Translation.tr("Switching to the current workspace goes back to the last one")
            option: "binds:workspace_back_and_forth"
        }

        HyprlandSwitch {
            buttonIcon: "repeat"
            text: Translation.tr("Moving past the last workspace wraps around")
            option: "binds:allow_workspace_cycles"
        }

        HyprlandSwitch {
            buttonIcon: "animation"
            text: Translation.tr("Animate the wrap around")
            option: "animations:workspace_wraparound"
        }

        HyprlandSwitch {
            buttonIcon: "layers_clear"
            text: Translation.tr("Hide the special workspace when switching")
            option: "binds:hide_special_on_workspace_change"
        }

        HyprlandSwitch {
            buttonIcon: "close"
            text: Translation.tr("Close the special workspace once it is empty")
            option: "misc:close_special_on_empty"
        }

        ContentSubsection {
            title: Translation.tr("Distance between workspaces")
            tooltip: Translation.tr("How far apart two workspaces sit while the switch is animating")

            OptionSpinBox {
                icon: "width"
                text: Translation.tr("Gap (px)")
                current: HyprlandOptions.number("general:gaps_workspaces")
                from: 0
                to: 500
                stepSize: 10
                onCommitted: gap => HyprlandOptions.set("general:gaps_workspaces", gap)
            }
        }
    }
}
