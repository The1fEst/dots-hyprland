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

    property bool showsCurrent: false

    onValueChanged: {
        if (root.value === root.current) {
            root.showsCurrent = true;
            return;
        }
        if (root.showsCurrent)
            root.committed(root.value);
    }

    Binding {
        target: root
        property: "value"
        value: root.current
    }
}
