import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

/**
 * One thing hypridle does after a while: whether it happens at all, and how long it waits.
 */
ContentSubsection {
    id: root

    required property string what
    required property string switchIcon
    required property string switchText
    required property int fallbackMinutes

    readonly property int minutes: Math.round(IdleOptions.seconds(root.what) / 60)

    ConfigRow {
        uniform: false
        Layout.fillWidth: false

        OptionSwitch {
            buttonIcon: root.switchIcon
            text: root.switchText
            current: root.minutes > 0
            onCommitted: wanted => IdleOptions.set(root.what, wanted ? root.fallbackMinutes * 60 : 0)
        }

        OptionSpinBox {
            enabled: root.minutes > 0
            icon: "timer"
            text: Translation.tr("after (min)")
            current: root.minutes
            from: 1
            to: 600
            stepSize: 5
            onCommitted: minutes => IdleOptions.set(root.what, minutes * 60)
        }
    }
}
