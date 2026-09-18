import qs.modules.common.widgets
import QtQuick

ConfigSpinBox {
    id: root

    required property real current

    signal committed(real value)

    onValueChanged: {
        if (value !== root.current)
            root.committed(value);
    }

    Binding {
        target: root
        property: "value"
        value: root.current
    }
}
