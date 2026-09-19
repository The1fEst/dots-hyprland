import qs.modules.common.widgets
import QtQuick

/**
 * A switch for one setting: it shows `current` and emits `committed` once a person
 * flips it. Following the setting itself is what keeps a failed or overridden write
 * from leaving the switch in a state nothing is actually in.
 */
ConfigSwitch {
    id: root

    required property bool current

    signal committed(bool value)

    onCheckedChanged: if (root.checked !== root.current)
        root.committed(root.checked)

    Binding {
        target: root
        property: "checked"
        value: root.current
    }
}
