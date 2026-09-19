import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    forceWidth: true



    ContentSection {
        icon: "memory"
        title: Translation.tr("Resources")

        ConfigSpinBox {
            icon: "av_timer"
            text: Translation.tr("Polling interval (ms)")
            value: Config.options.resources.updateInterval
            from: 100
            to: 10000
            stepSize: 100
            onValueChanged: {
                Config.options.resources.updateInterval = value;
            }
        }

        ConfigSpinBox {
            icon: "timeline"
            text: Translation.tr("History length (data points)")
            value: Config.options.resources.historyLength
            from: 10
            to: 500
            stepSize: 10
            onValueChanged: {
                Config.options.resources.historyLength = value;
            }
            StyledToolTip {
                text: Translation.tr("How many measurements the usage graphs keep")
            }
        }
    }

    ContentSection {
        icon: "block"
        title: Translation.tr("Conflict killer")

        ConfigSwitch {
            buttonIcon: "notifications_off"
            text: Translation.tr("Kill notification daemons without asking")
            checked: Config.options.conflictKiller.autoKillNotificationDaemons
            onCheckedChanged: {
                Config.options.conflictKiller.autoKillNotificationDaemons = checked;
            }
            StyledToolTip {
                text: Translation.tr("Conflicting daemons like dunst or mako are killed silently instead of showing a dialog")
            }
        }

        ConfigSwitch {
            buttonIcon: "shelf_auto_hide"
            text: Translation.tr("Kill tray hosts without asking")
            checked: Config.options.conflictKiller.autoKillTrays
            onCheckedChanged: {
                Config.options.conflictKiller.autoKillTrays = checked;
            }
            StyledToolTip {
                text: Translation.tr("Other panels holding the system tray are killed silently instead of showing a dialog")
            }
        }
    }


    ContentSection {
        icon: "deployed_code_update"
        title: Translation.tr("System updates (Arch only)")

        ConfigSwitch {
            buttonIcon: "check"
            text: Translation.tr("Enable update checks")
            checked: Config.options.updates.enableCheck
            onCheckedChanged: {
                Config.options.updates.enableCheck = checked;
            }
            StyledToolTip {
                text: Translation.tr("Counts available packages. Nothing in the bar shows the count yet.")
            }
        }

        ConfigSpinBox {
            icon: "av_timer"
            text: Translation.tr("Check interval (mins)")
            enabled: Config.options.updates.enableCheck
            value: Config.options.updates.checkInterval
            from: 60
            to: 1440
            stepSize: 60
            onValueChanged: {
                Config.options.updates.checkInterval = value;
            }
        }

        ContentSubsection {
            title: Translation.tr("Pending package thresholds")
            enabled: Config.options.updates.enableCheck

            ConfigSpinBox {
                icon: "info"
                text: Translation.tr("Advise updating at")
                value: Config.options.updates.adviseUpdateThreshold
                from: 1
                to: 1000
                stepSize: 25
                onValueChanged: {
                    Config.options.updates.adviseUpdateThreshold = value;
                }
            }

            ConfigSpinBox {
                icon: "warning"
                text: Translation.tr("Strongly advise updating at")
                value: Config.options.updates.stronglyAdviseUpdateThreshold
                from: 1
                to: 2000
                stepSize: 25
                onValueChanged: {
                    Config.options.updates.stronglyAdviseUpdateThreshold = value;
                }
            }
        }
    }

    ContentSection {
        icon: "weather_mix"
        title: Translation.tr("Weather")
        ConfigRow {
            ConfigSwitch {
                buttonIcon: "assistant_navigation"
                text: Translation.tr("Enable GPS based location")
                checked: Config.options.bar.weather.enableGPS
                onCheckedChanged: {
                    Config.options.bar.weather.enableGPS = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "thermometer"
                text: Translation.tr("Fahrenheit unit")
                checked: Config.options.bar.weather.useUSCS
                onCheckedChanged: {
                    Config.options.bar.weather.useUSCS = checked;
                }
                StyledToolTip {
                    text: Translation.tr("It may take a few seconds to update")
                }
            }
        }
        
        MaterialTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("City name")
            text: Config.options.bar.weather.city
            wrapMode: TextEdit.Wrap
            onTextChanged: {
                Config.options.bar.weather.city = text;
            }
        }
        ConfigSpinBox {
            icon: "av_timer"
            text: Translation.tr("Polling interval (m)")
            value: Config.options.bar.weather.fetchInterval
            from: 5
            to: 50
            stepSize: 5
            onValueChanged: {
                Config.options.bar.weather.fetchInterval = value;
            }
        }
    }
}
