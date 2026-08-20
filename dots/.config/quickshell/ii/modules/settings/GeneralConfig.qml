import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

ContentPage {
    forceWidth: true

    ContentSection {
        icon: "volume_up"
        title: Translation.tr("Audio")

        ConfigSwitch {
            buttonIcon: "hearing"
            text: Translation.tr("Earbang protection")
            checked: Config.options.audio.protection.enable
            onCheckedChanged: {
                Config.options.audio.protection.enable = checked;
            }
            StyledToolTip {
                text: Translation.tr("Prevents abrupt increments and restricts volume limit")
            }
        }
        ConfigRow {
            enabled: Config.options.audio.protection.enable
            ConfigSpinBox {
                icon: "arrow_warm_up"
                text: Translation.tr("Max allowed increase")
                value: Config.options.audio.protection.maxAllowedIncrease
                from: 0
                to: 100
                stepSize: 2
                onValueChanged: {
                    Config.options.audio.protection.maxAllowedIncrease = value;
                }
            }
            ConfigSpinBox {
                icon: "vertical_align_top"
                text: Translation.tr("Volume limit")
                value: Config.options.audio.protection.maxAllowed
                from: 0
                to: 154 // pavucontrol allows up to 153%
                stepSize: 2
                onValueChanged: {
                    Config.options.audio.protection.maxAllowed = value;
                }
            }
        }
    }

    ContentSection {
        icon: "apps"
        title: Translation.tr("Applications")

        ContentSubsection {
            title: Translation.tr("Commands")
            tooltip: Translation.tr("Programs launched by shell actions and buttons")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Terminal")
                text: Config.options.apps.terminal
                onEditingFinished: {
                    Config.options.apps.terminal = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Task manager")
                text: Config.options.apps.taskManager
                onEditingFinished: {
                    Config.options.apps.taskManager = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Volume mixer")
                text: Config.options.apps.volumeMixer
                onEditingFinished: {
                    Config.options.apps.volumeMixer = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Bluetooth settings")
                text: Config.options.apps.bluetooth
                onEditingFinished: {
                    Config.options.apps.bluetooth = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Network settings")
                text: Config.options.apps.network
                onEditingFinished: {
                    Config.options.apps.network = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Ethernet settings")
                text: Config.options.apps.networkEthernet
                onEditingFinished: {
                    Config.options.apps.networkEthernet = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("User management")
                text: Config.options.apps.manageUser
                onEditingFinished: {
                    Config.options.apps.manageUser = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Change password")
                text: Config.options.apps.changePassword
                onEditingFinished: {
                    Config.options.apps.changePassword = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("System update")
                text: Config.options.apps.update
                onEditingFinished: {
                    Config.options.apps.update = text;
                }
            }
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
        icon: "calendar_month"
        title: Translation.tr("Calendar")

        MaterialTextField {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            placeholderText: Translation.tr("Locale (e.g. en-GB, determines the first day of week)")
            text: Config.options.calendar.locale
            onEditingFinished: {
                Config.options.calendar.locale = text.trim();
            }
        }
    }

    ContentSection {
        icon: "language"
        title: Translation.tr("Language")

        ContentSubsection {
            title: Translation.tr("Interface Language")
            tooltip: Translation.tr("Select the language for the user interface.\n\"Auto\" will use your system's locale.")

            StyledComboBox {
                id: languageSelector
                buttonIcon: "language"
                textRole: "displayName"

                model: [
                    {
                        displayName: Translation.tr("Auto (System)"),
                        value: "auto"
                    },
                    ...Translation.allAvailableLanguages.map(lang => {
                        return {
                            displayName: lang,
                            value: lang
                        };
                    })]

                currentIndex: {
                    const index = model.findIndex(item => item.value === Config.options.language.ui);
                    return index !== -1 ? index : 0;
                }

                onActivated: index => {
                    Config.options.language.ui = model[index].value;
                }
            }
        }
    }

    ContentSection {
        icon: "notification_sound"
        title: Translation.tr("Sounds")
        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "battery_android_full"
                text: Translation.tr("Battery")
                checked: Config.options.sounds.battery
                onCheckedChanged: {
                    Config.options.sounds.battery = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "av_timer"
                text: Translation.tr("Pomodoro")
                checked: Config.options.sounds.pomodoro
                onCheckedChanged: {
                    Config.options.sounds.pomodoro = checked;
                }
            }
        }

        MaterialTextField {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            placeholderText: Translation.tr("Sound theme (e.g. freedesktop)")
            text: Config.options.sounds.theme
            onEditingFinished: {
                Config.options.sounds.theme = text.trim();
            }
        }
    }

    ContentSection {
        icon: "nest_clock_farsight_analog"
        title: Translation.tr("Time")

        ConfigSwitch {
            buttonIcon: "pace"
            text: Translation.tr("Second precision")
            checked: Config.options.time.secondPrecision
            onCheckedChanged: {
                Config.options.time.secondPrecision = checked;
            }
            StyledToolTip {
                text: Translation.tr("Enable if you want clocks to show seconds accurately")
            }
        }

        ContentSubsection {
            title: Translation.tr("Format")
            tooltip: ""

            ConfigSelectionArray {
                currentValue: Config.options.time.format
                onSelected: newValue => {
                    if (newValue === "hh:mm") {
                        Quickshell.execDetached(["bash", "-c", `sed -i 's/\\TIME12\\b/TIME/' '${FileUtils.trimFileProtocol(Directories.config)}/hypr/hyprlock.conf'`]);
                    } else {
                        Quickshell.execDetached(["bash", "-c", `sed -i 's/\\TIME\\b/TIME12/' '${FileUtils.trimFileProtocol(Directories.config)}/hypr/hyprlock.conf'`]);
                    }

                    Config.options.time.format = newValue;
                }
                options: [
                    {
                        displayName: Translation.tr("24h"),
                        value: "hh:mm"
                    },
                    {
                        displayName: Translation.tr("12h am/pm"),
                        value: "h:mm ap"
                    },
                    {
                        displayName: Translation.tr("12h AM/PM"),
                        value: "h:mm AP"
                    },
                ]
            }
        }

        ContentSubsection {
            title: Translation.tr("Date formats")
            tooltip: Translation.tr("Qt date format strings, see https://doc.qt.io/qt-6/qdate.html#toString")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Date (e.g. ddd, dd/MM)")
                text: Config.options.time.dateFormat
                onEditingFinished: {
                    Config.options.time.dateFormat = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Short date (e.g. dd/MM)")
                text: Config.options.time.shortDateFormat
                onEditingFinished: {
                    Config.options.time.shortDateFormat = text;
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Date with year (e.g. dd/MM/yyyy)")
                text: Config.options.time.dateWithYearFormat
                onEditingFinished: {
                    Config.options.time.dateWithYearFormat = text;
                }
            }
        }

        ContentSubsection {
            title: Translation.tr("Pomodoro")

            ConfigRow {
                uniform: true
                ConfigSpinBox {
                    icon: "target"
                    text: Translation.tr("Focus (min)")
                    value: Math.round(Config.options.time.pomodoro.focus / 60)
                    from: 1
                    to: 180
                    stepSize: 5
                    onValueChanged: {
                        Config.options.time.pomodoro.focus = value * 60;
                    }
                }
                ConfigSpinBox {
                    icon: "coffee"
                    text: Translation.tr("Break (min)")
                    value: Math.round(Config.options.time.pomodoro.breakTime / 60)
                    from: 1
                    to: 60
                    stepSize: 1
                    onValueChanged: {
                        Config.options.time.pomodoro.breakTime = value * 60;
                    }
                }
            }
            ConfigRow {
                uniform: true
                ConfigSpinBox {
                    icon: "airline_seat_recline_extra"
                    text: Translation.tr("Long break (min)")
                    value: Math.round(Config.options.time.pomodoro.longBreak / 60)
                    from: 1
                    to: 120
                    stepSize: 5
                    onValueChanged: {
                        Config.options.time.pomodoro.longBreak = value * 60;
                    }
                }
                ConfigSpinBox {
                    icon: "repeat"
                    text: Translation.tr("Cycles before long break")
                    value: Config.options.time.pomodoro.cyclesBeforeLongBreak
                    from: 1
                    to: 12
                    stepSize: 1
                    onValueChanged: {
                        Config.options.time.pomodoro.cyclesBeforeLongBreak = value;
                    }
                }
            }
        }
    }

    ContentSection {
        icon: "work_alert"
        title: Translation.tr("Work safety")

        ConfigSwitch {
            buttonIcon: "assignment"
            text: Translation.tr("Hide clipboard images copied from sussy sources")
            checked: Config.options.workSafety.enable.clipboard
            onCheckedChanged: {
                Config.options.workSafety.enable.clipboard = checked;
            }
        }
        ConfigSwitch {
            buttonIcon: "wallpaper"
            text: Translation.tr("Hide sussy/anime wallpapers")
            checked: Config.options.workSafety.enable.wallpaper
            onCheckedChanged: {
                Config.options.workSafety.enable.wallpaper = checked;
            }
        }

        ContentSubsection {
            title: Translation.tr("Trigger keywords")
            tooltip: Translation.tr("Comma-separated. Work safety kicks in when one of these shows up.")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Network names")
                text: (Config.options.workSafety.triggerCondition.networkNameKeywords ?? []).join(", ")
                onEditingFinished: {
                    Config.options.workSafety.triggerCondition.networkNameKeywords = StringUtils.splitList(text);
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("File names")
                text: (Config.options.workSafety.triggerCondition.fileKeywords ?? []).join(", ")
                onEditingFinished: {
                    Config.options.workSafety.triggerCondition.fileKeywords = StringUtils.splitList(text);
                }
            }
            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Links")
                text: (Config.options.workSafety.triggerCondition.linkKeywords ?? []).join(", ")
                onEditingFinished: {
                    Config.options.workSafety.triggerCondition.linkKeywords = StringUtils.splitList(text);
                }
            }
        }
    }
}
