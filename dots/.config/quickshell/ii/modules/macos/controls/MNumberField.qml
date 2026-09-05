pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Row {
    id: root

    property int value: 0
    property int from: 0
    property int to: 999
    property int step: 1
    property real fieldWidth: 34
    property bool available: true

    signal edited(int value)

    spacing: 6
    enabled: root.available
    opacity: root.available ? 1 : 0.4

    function commit(next: int): void {
        const bounded = isNaN(next) ? root.value : Math.max(root.from, Math.min(root.to, next));
        field.text = String(bounded);
        if (bounded !== root.value)
            root.edited(bounded);
    }

    onValueChanged: field.text = String(root.value)

    MTextField {
        id: field
        anchors.verticalCenter: parent.verticalCenter
        text: String(root.value)
        fieldWidth: root.fieldWidth
        validator: IntValidator {
            bottom: root.from
            top: root.to
        }
        onCommitted: entered => root.commit(parseInt(entered))
    }

    MStepper {
        anchors.verticalCenter: parent.verticalCenter
        upAvailable: root.value < root.to
        downAvailable: root.value > root.from
        onStepped: delta => root.commit(root.value + delta * root.step)
    }
}
