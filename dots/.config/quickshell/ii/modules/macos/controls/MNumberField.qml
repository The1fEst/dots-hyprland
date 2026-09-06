pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Row {
    id: root

    property real value: 0
    property real from: 0
    property real to: 999
    property real step: 1
    property int decimals: 0
    property real fieldWidth: 34
    property bool available: true

    signal edited(real value)

    spacing: 6
    enabled: root.available
    opacity: root.available ? 1 : 0.4

    function shown(number: real): string {
        return number.toFixed(root.decimals);
    }

    function commit(next: real): void {
        const bounded = isNaN(next) ? root.value : Math.max(root.from, Math.min(root.to, next));
        const rounded = Number(bounded.toFixed(root.decimals));
        field.text = root.shown(rounded);
        if (rounded !== root.value)
            root.edited(rounded);
    }

    onValueChanged: field.text = root.shown(root.value)

    MTextField {
        id: field
        anchors.verticalCenter: parent.verticalCenter
        text: root.shown(root.value)
        fieldWidth: root.fieldWidth
        validator: DoubleValidator {
            bottom: root.from
            top: root.to
            decimals: root.decimals
            notation: DoubleValidator.StandardNotation
        }
        onCommitted: entered => root.commit(parseFloat(entered))
    }

    MStepper {
        anchors.verticalCenter: parent.verticalCenter
        upAvailable: root.value < root.to
        downAvailable: root.value > root.from
        onStepped: delta => root.commit(root.value + delta * root.step)
    }
}
