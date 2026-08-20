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
        icon: "file_open"
        title: Translation.tr("Save paths")

        MaterialTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Video Recording Path")
            text: Config.options.screenRecord.savePath
            wrapMode: TextEdit.Wrap
            onTextChanged: {
                Config.options.screenRecord.savePath = text;
            }
        }
        
        MaterialTextArea {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Screenshot Path (leave empty to just copy)")
            text: Config.options.screenSnip.savePath
            wrapMode: TextEdit.Wrap
            onTextChanged: {
                Config.options.screenSnip.savePath = text;
            }
        }
    }

    ContentSection {
        icon: "search"
        title: Translation.tr("Search")

        ConfigSwitch {
            text: Translation.tr("Use Levenshtein distance-based algorithm instead of fuzzy")
            checked: Config.options.search.sloppy
            onCheckedChanged: {
                Config.options.search.sloppy = checked;
            }
            StyledToolTip {
                text: Translation.tr("Could be better if you make a ton of typos,\nbut results can be weird and might not work with acronyms\n(e.g. \"GIMP\" might not give you the paint program)")
            }
        }

        ConfigSpinBox {
            icon: "av_timer"
            text: Translation.tr("Non-app result delay (ms)")
            value: Config.options.search.nonAppResultDelay
            from: 0
            to: 500
            stepSize: 10
            onValueChanged: {
                Config.options.search.nonAppResultDelay = value;
            }
            StyledToolTip {
                text: Translation.tr("Delays the expensive result types (math, commands, web) so typing stays smooth")
            }
        }

        ContentSubsection {
            title: Translation.tr("Prefixes")

            ConfigSwitch {
                buttonIcon: "bolt"
                text: Translation.tr("Show default actions without a prefix")
                checked: Config.options.search.prefix.showDefaultActionsWithoutPrefix
                onCheckedChanged: {
                    Config.options.search.prefix.showDefaultActionsWithoutPrefix = checked;
                }
            }

            ConfigRow {
                uniform: true
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Apps")
                    text: Config.options.search.prefix.app
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.app = text;
                    }
                }
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Action")
                    text: Config.options.search.prefix.action
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.action = text;
                    }
                }
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Clipboard")
                    text: Config.options.search.prefix.clipboard
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.clipboard = text;
                    }
                }
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Emojis")
                    text: Config.options.search.prefix.emojis
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.emojis = text;
                    }
                }
            }

            ConfigRow {
                uniform: true
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Math")
                    text: Config.options.search.prefix.math
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.math = text;
                    }
                }
                MaterialTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Shell command")
                    text: Config.options.search.prefix.shellCommand
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        Config.options.search.prefix.shellCommand = text;
                    }
                }
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
                text: Translation.tr("Only the Waffle panel shows an update indicator; the ii bar doesn't have one")
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
