import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: root

    forceWidth: true

    function deviceLabel(node: var): string {
        const description = node?.description ?? "";
        const device = node?.nickname ?? "";
        if (device.length > 0 && description.length > device.length && description.startsWith(device))
            return `${device} · ${description.slice(device.length).trim()}`;
        return description || device || node?.name || "";
    }

    function deviceOptions(devices: var): var {
        return devices.map(node => ({
                    displayName: root.deviceLabel(node),
                    value: node
                }));
    }

    function indexOfDevice(options: var, node: var): int {
        const found = options.findIndex(option => option.value === node);
        return found !== -1 ? found : 0;
    }

    ContentSection {
        icon: "volume_up"
        title: Translation.tr("Output")

        ContentSubsection {
            title: Translation.tr("Device")

            StyledComboBox {
                buttonIcon: "speaker"
                textRole: "displayName"
                model: root.deviceOptions(Audio.outputDevices)
                boundIndex: root.indexOfDevice(model, Audio.sink)
                onActivated: index => Audio.setDefaultSink(model[index].value)
            }
        }

        ConfigSlider {
            text: Translation.tr("Volume")
            buttonIcon: "volume_up"
            from: 0
            to: 100
            value: Math.round((Audio.sink?.audio.volume ?? 0) * 100)
            onMoved: newValue => {
                if (Audio.sink)
                    Audio.sink.audio.volume = newValue / 100;
            }
        }

        ConfigSwitch {
            buttonIcon: "volume_off"
            text: Translation.tr("Mute")
            checked: Audio.sink?.audio.muted ?? false
            onCheckedChanged: {
                if (Audio.sink && Audio.sink.audio.muted !== checked)
                    Audio.sink.audio.muted = checked;
            }
        }
    }

    ContentSection {
        icon: "mic"
        title: Translation.tr("Input")

        ContentSubsection {
            title: Translation.tr("Device")

            StyledComboBox {
                buttonIcon: "mic"
                textRole: "displayName"
                model: root.deviceOptions(Audio.inputDevices)
                boundIndex: root.indexOfDevice(model, Audio.source)
                onActivated: index => Audio.setDefaultSource(model[index].value)
            }
        }

        ConfigSlider {
            text: Translation.tr("Volume")
            buttonIcon: "mic"
            from: 0
            to: 100
            value: Math.round((Audio.source?.audio.volume ?? 0) * 100)
            onMoved: newValue => {
                if (Audio.source)
                    Audio.source.audio.volume = newValue / 100;
            }
        }

        ConfigSwitch {
            buttonIcon: "mic_off"
            text: Translation.tr("Mute")
            checked: Audio.source?.audio.muted ?? false
            onCheckedChanged: {
                if (Audio.source && Audio.source.audio.muted !== checked)
                    Audio.source.audio.muted = checked;
            }
        }
    }

    ContentSection {
        icon: "tune"
        title: Translation.tr("Volume Levels")

        PwObjectTracker {
            objects: Audio.outputAppNodes
        }

        StyledText {
            visible: Audio.outputAppNodes.length === 0
            Layout.leftMargin: 8
            text: Translation.tr("Nothing is playing")
            color: Appearance.colors.colSubtext
        }

        Repeater {
            model: Audio.outputAppNodes

            delegate: ConfigSlider {
                id: appVolume
                required property var modelData

                text: Audio.appNodeDisplayName(appVolume.modelData)
                buttonIcon: appVolume.modelData?.audio.muted ? "volume_off" : "volume_up"
                from: 0
                to: 100
                value: Math.round((appVolume.modelData?.audio.volume ?? 0) * 100)
                onMoved: newValue => {
                    if (appVolume.modelData)
                        appVolume.modelData.audio.volume = newValue / 100;
                }
            }
        }
    }

    ContentSection {
        icon: "notification_sound"
        title: Translation.tr("Alert Sound")

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

        ContentSubsection {
            title: Translation.tr("Sound theme")

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("e.g. freedesktop")
                text: Config.options.sounds.theme
                onEditingFinished: {
                    Config.options.sounds.theme = text.trim();
                }
            }
        }
    }

    ContentSection {
        icon: "speaker"
        title: Translation.tr("Sound cards")

        Repeater {
            model: AudioCards.cards

            ContentSubsection {
                id: card

                required property var modelData

                title: card.modelData.description
                tooltip: Translation.tr("Which of the card's input and output configurations PipeWire uses")

                StyledComboBox {
                    buttonIcon: "tune"
                    textRole: "label"
                    model: card.modelData.profiles
                    boundIndex: Math.max(0, card.modelData.profiles.findIndex(profile => profile.value === card.modelData.active))
                    onActivated: index => AudioCards.setProfile(card.modelData.name, card.modelData.profiles[index].value)
                }
            }
        }
    }

    ContentSection {
        icon: "hearing"
        title: Translation.tr("Earbang protection")

        ConfigSwitch {
            buttonIcon: "hearing"
            text: Translation.tr("Enable")
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
                to: 154
                stepSize: 2
                onValueChanged: {
                    Config.options.audio.protection.maxAllowed = value;
                }
            }
        }
    }

}
