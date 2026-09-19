import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    ContentSection {
        ContentSubsection {
            title: Translation.tr("Time Format")

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
    }

    ContentSection {
        icon: "nest_clock_farsight_analog"
        title: Translation.tr("Clock & Calendar")

        ConfigSwitch {
            buttonIcon: "pace"
            text: Translation.tr("Seconds")
            checked: Config.options.time.secondPrecision
            onCheckedChanged: {
                Config.options.time.secondPrecision = checked;
            }
            StyledToolTip {
                text: Translation.tr("Enable if you want clocks to show seconds accurately")
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
    }

    ContentSection {
        icon: "timer"
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
                StyledToolTip {
                    text: Translation.tr("Cycles before long break")
                }
            }
        }
    }
}
