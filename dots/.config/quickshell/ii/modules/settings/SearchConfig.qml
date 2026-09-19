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
                OptionTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Apps")
                    current: Config.options.search.prefix.app
                    wrapMode: TextEdit.Wrap
                    onCommitted: value => Config.options.search.prefix.app = value
                }
                OptionTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Action")
                    current: Config.options.search.prefix.action
                    wrapMode: TextEdit.Wrap
                    onCommitted: value => Config.options.search.prefix.action = value
                }
                OptionTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Clipboard")
                    current: Config.options.search.prefix.clipboard
                    wrapMode: TextEdit.Wrap
                    onCommitted: value => Config.options.search.prefix.clipboard = value
                }
                OptionTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Emojis")
                    current: Config.options.search.prefix.emojis
                    wrapMode: TextEdit.Wrap
                    onCommitted: value => Config.options.search.prefix.emojis = value
                }
            }

            ConfigRow {
                uniform: true
                OptionTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Math")
                    current: Config.options.search.prefix.math
                    wrapMode: TextEdit.Wrap
                    onCommitted: value => Config.options.search.prefix.math = value
                }
                OptionTextArea {
                    Layout.fillWidth: true
                    placeholderText: Translation.tr("Shell command")
                    current: Config.options.search.prefix.shellCommand
                    wrapMode: TextEdit.Wrap
                    onCommitted: value => Config.options.search.prefix.shellCommand = value
                }
            }
        }
    }
}
