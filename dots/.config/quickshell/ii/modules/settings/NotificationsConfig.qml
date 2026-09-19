import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    ContentSection {
        ConfigSwitch {
            buttonIcon: "notifications_paused"
            text: Translation.tr("Do not disturb")
            checked: Notifications.silent
            onCheckedChanged: {
                if (Notifications.silent !== checked)
                    Notifications.setSilent(checked);
            }

            StyledToolTip {
                text: Translation.tr("Notifications still arrive and are kept; they just do not pop up.")
            }
        }

        ConfigSpinBox {
            icon: "av_timer"
            text: Translation.tr("Stays on screen for (ms)")
            value: Config.options.notifications.timeout
            from: 1000
            to: 60000
            stepSize: 1000
            onValueChanged: {
                Config.options.notifications.timeout = value;
            }

            StyledToolTip {
                text: Translation.tr("Used for notifications that do not ask for a time of their own")
            }
        }

        ContentSubsection {
            title: Translation.tr("Placement")

            ConfigSwitch {
                buttonIcon: "monitor"
                text: Translation.tr("Always on one display")
                checked: Config.options.notifications.forceMonitor.enable
                onCheckedChanged: {
                    Config.options.notifications.forceMonitor.enable = checked;
                }
                StyledToolTip {
                    text: Translation.tr("With multiple monitors, keeps notifications on the one picked below")
                }
            }

            StyledComboBox {
                enabled: Config.options.notifications.forceMonitor.enable
                buttonIcon: "monitor"
                textRole: "displayName"
                model: HyprlandData.monitors.map(monitor => ({
                            displayName: `${monitor.model || monitor.name} (${monitor.name})`,
                            value: monitor.name
                        }))
                boundIndex: Math.max(0, model.findIndex(item => item.value === Config.options.notifications.forceMonitor.name))
                onActivated: index => {
                    Config.options.notifications.forceMonitor.name = model[index].value;
                }
            }
        }
    }

    ContentSection {
        icon: "voting_chip"
        title: Translation.tr("On-screen display")

        ConfigSpinBox {
            icon: "av_timer"
            text: Translation.tr("Stays on screen for (ms)")
            value: Config.options.osd.timeout
            from: 100
            to: 3000
            stepSize: 100
            onValueChanged: {
                Config.options.osd.timeout = value;
            }
        }
    }
}
