import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    component IdleRow: ContentSubsection {
        id: idleRow

        required property string what
        required property string switchIcon
        required property string switchText
        required property int fallbackMinutes

        readonly property int minutes: Math.round(IdleOptions.seconds(idleRow.what) / 60)

        ConfigRow {
            uniform: false
            Layout.fillWidth: false

            OptionSwitch {
                buttonIcon: idleRow.switchIcon
                text: idleRow.switchText
                current: idleRow.minutes > 0
                onCommitted: wanted => IdleOptions.set(idleRow.what, wanted ? idleRow.fallbackMinutes * 60 : 0)
            }

            OptionSpinBox {
                enabled: idleRow.minutes > 0
                icon: "timer"
                text: Translation.tr("after (min)")
                current: idleRow.minutes
                from: 1
                to: 600
                stepSize: 5
                onCommitted: minutes => IdleOptions.set(idleRow.what, minutes * 60)
            }
        }
    }

    ContentSection {
        icon: "energy_savings_leaf"
        title: Translation.tr("Power Saving")

        IdleRow {
            title: Translation.tr("Automatic screen blank")
            tooltip: Translation.tr("Turns the screens off after a period of inactivity")
            what: "screen"
            switchIcon: "brightness_low"
            switchText: Translation.tr("Blank the screen")
            fallbackMinutes: 15
        }

        IdleRow {
            title: Translation.tr("Automatic screen lock")
            tooltip: Translation.tr("Locks the session after a period of inactivity")
            what: "lock"
            switchIcon: "lock_clock"
            switchText: Translation.tr("Lock the session")
            fallbackMinutes: 30
        }
    }

    ContentSection {
        icon: "battery_android_full"
        title: Translation.tr("Battery")

        ConfigRow {
            uniform: true
            ConfigSpinBox {
                icon: "warning"
                text: Translation.tr("Low warning")
                value: Config.options.battery.low
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.battery.low = value;
                }
            }
            ConfigSpinBox {
                icon: "dangerous"
                text: Translation.tr("Critical warning")
                value: Config.options.battery.critical
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.battery.critical = value;
                }
            }
        }
        ConfigRow {
            uniform: false
            Layout.fillWidth: false
            ConfigSwitch {
                buttonIcon: "pause"
                text: Translation.tr("Automatic suspend")
                checked: Config.options.battery.automaticSuspend
                onCheckedChanged: {
                    Config.options.battery.automaticSuspend = checked;
                }
                StyledToolTip {
                    text: Translation.tr("Automatically suspends the system when battery is low")
                }
            }
            ConfigSpinBox {
                enabled: Config.options.battery.automaticSuspend
                text: Translation.tr("at")
                value: Config.options.battery.suspend
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.battery.suspend = value;
                }
            }
        }
        ConfigRow {
            uniform: true
            ConfigSpinBox {
                icon: "charger"
                text: Translation.tr("Full warning")
                value: Config.options.battery.full
                from: 0
                to: 101
                stepSize: 5
                onValueChanged: {
                    Config.options.battery.full = value;
                }
            }
        }
    }

    ContentSection {
        icon: "bedtime"
        title: Translation.tr("Automatic Suspend")

        IdleRow {
            title: Translation.tr("Suspend when idle")
            tooltip: Translation.tr("Turning automatic suspend off means the machine keeps drawing power while nobody is at it")
            what: "suspend"
            switchIcon: "pause"
            switchText: Translation.tr("Suspend")
            fallbackMinutes: 45
        }
    }
}
