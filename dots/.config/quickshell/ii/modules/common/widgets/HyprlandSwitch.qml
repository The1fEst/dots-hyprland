import qs.services
import qs.modules.common.widgets

/**
 * A switch for one Hyprland option, named the way hyprctl names it, such as
 * input:numlock_by_default.
 */
OptionSwitch {
    id: root

    required property string option

    current: HyprlandOptions.flag(root.option)
    onCommitted: value => HyprlandOptions.set(root.option, value)
}
