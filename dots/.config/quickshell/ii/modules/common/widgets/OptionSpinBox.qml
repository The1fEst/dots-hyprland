import qs.modules.common.widgets
import QtQuick

/**
 * A spin box for one setting: it shows `current` and emits `committed` once a person
 * changes it. A value the box clamps into its own range on the way in is not a change
 * a person made, so it is never committed.
 */
ConfigSpinBox {
    id: root

    required property real current

    signal committed(real value)

    readonly property real shown: Math.min(Math.max(root.current, root.from), root.to)

    property bool live: false
    Component.onCompleted: root.live = true

    onValueChanged: {
        if (root.value === root.shown)
            return;
        if (root.live)
            root.committed(root.value);
    }

    Binding {
        target: root
        property: "value"
        value: root.shown
    }
}
