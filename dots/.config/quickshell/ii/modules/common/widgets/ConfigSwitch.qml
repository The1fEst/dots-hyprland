import qs.modules.common.widgets
import qs.modules.common
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

/**
 * A labelled switch. `checked` stays bound to whatever the page bound it to: a click
 * flips it only long enough for the page's handler to run, then hands the property
 * back to that binding, so the switch keeps showing the setting rather than the last
 * click when a write is rejected or the setting changes elsewhere.
 */
RippleButton {
    id: root
    property string buttonIcon
    property alias iconSize: iconWidget.iconSize

    Layout.fillWidth: true
    implicitHeight: contentItem.implicitHeight + 8 * 2
    font.pixelSize: Appearance.font.pixelSize.small

    onClicked: {
        flip.value = !root.checked;
        flip.when = true;
        flip.when = false;
    }

    Binding {
        id: flip
        target: root
        property: "checked"
        when: false
        restoreMode: Binding.RestoreBindingOrValue
    }

    contentItem: RowLayout {
        spacing: 10
        OptionalMaterialSymbol {
            id: iconWidget
            icon: root.buttonIcon
            opacity: root.enabled ? 1 : 0.4
            iconSize: Appearance.font.pixelSize.larger
        }
        StyledText {
            id: labelWidget
            Layout.fillWidth: true
            text: root.text
            font: root.font
            color: Appearance.colors.colOnSecondaryContainer
            opacity: root.enabled ? 1 : 0.4
        }
        StyledSwitch {
            id: switchWidget
            down: root.down
            Layout.fillWidth: false
            checked: root.checked
            onClicked: root.clicked()
        }
    }
}

