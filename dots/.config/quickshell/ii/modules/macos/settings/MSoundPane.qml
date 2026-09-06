pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.services
import qs.modules.macos.controls
import qs.modules.macos.looks

Column {
    id: root

    property bool showingInput: false

    readonly property list<var> devices: root.showingInput ? Audio.inputDevices : Audio.outputDevices
    readonly property var current: root.showingInput ? Audio.source : Audio.sink

    function typeOf(node: var): string {
        const name = node.name ?? "";
        if (name.includes(".monitor"))
            return qsTr("Monitor");
        if (name.includes("bluez"))
            return qsTr("Bluetooth");
        if (name.includes("usb"))
            return qsTr("USB");
        if (name.includes("pci"))
            return qsTr("Built-in");
        return qsTr("Virtual");
    }

    spacing: Looks.settings.formGap

    MText {
        x: Looks.settings.formRowInset
        text: qsTr("Output & Input")
        textStyle: Looks.font.style.headline
    }

    MSettingsGroup {
        width: parent.width

        Item {
            implicitWidth: parent?.width ?? 0
            implicitHeight: Looks.settings.formRowHeight

            MSegmentedControl {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Looks.settings.formRowInset
                    rightMargin: Looks.settings.formRowInset
                    verticalCenter: parent.verticalCenter
                }
                segments: [qsTr("Output"), qsTr("Input")]
                current: root.showingInput ? 1 : 0
                onSelected: index => root.showingInput = index === 1
            }
        }

        MTableRow {
            label: qsTr("Name")
            detail: qsTr("Type")
            header: true
        }

        Repeater {
            model: root.devices

            MTableRow {
                required property var modelData

                label: modelData.description || modelData.nickname || modelData.name
                detail: root.typeOf(modelData)
                selected: modelData === root.current
                onClicked: {
                    if (root.showingInput)
                        Pipewire.preferredDefaultAudioSource = modelData;
                    else
                        Pipewire.preferredDefaultAudioSink = modelData;
                }
            }
        }

    }

    MSettingsGroup {
        width: parent.width

        MSettingsRow {
            label: root.showingInput ? qsTr("Input volume") : qsTr("Output volume")
            separator: !root.showingInput

            MSlider {
                value: root.current?.audio.volume ?? 0
                onMoved: level => {
                    if (root.current)
                        root.current.audio.volume = level;
                }
            }
        }

        MSettingsRow {
            label: qsTr("Mute")
            visible: !root.showingInput
            separator: false

            MSwitch {
                checked: root.current?.audio.muted ?? false
                onToggled: on => {
                    if (root.current)
                        root.current.audio.muted = on;
                }
            }
        }
    }

    MText {
        x: Looks.settings.formRowInset
        text: qsTr("Configuration")
        textStyle: Looks.font.style.headline
    }

    MSettingsGroup {
        width: parent.width

        Repeater {
            model: MAudioCards.cards

            MSettingsRow {
                required property var modelData
                required property int index

                label: modelData.description
                separator: index < MAudioCards.cards.length - 1

                MPopupButton {
                    current: modelData.active
                    options: modelData.profiles
                    onSelected: value => MAudioCards.setProfile(modelData.name, value)
                }
            }
        }
    }

}
