pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.modules.common
import qs.modules.common.models.quickToggles
import qs.modules.macos.looks

PanelWindow {
    id: root

    required property var screenData
    property bool open: false

    readonly property real sideMargin: 12
    readonly property real cellSpacing: 10
    readonly property int columns: 4
    readonly property real cellWidth: 70
    readonly property real cellHeight: 62

    readonly property var controls: Config.options?.macos.controlCenter.controls ?? []

    function specFor(id) {
        switch (id) {
        case "network":
            return {
                component: networkControl,
                cols: 2,
                rows: 1
            };
        case "bluetooth":
            return {
                component: bluetoothControl,
                cols: 2,
                rows: 1
            };
        case "media":
            return {
                component: mediaControl,
                cols: 2,
                rows: 2
            };
        case "volume":
            return {
                component: volumeControl,
                cols: 4,
                rows: 1
            };
        case "brightness":
            return {
                component: brightnessControl,
                cols: 4,
                rows: 1
            };
        case "darkMode":
            return {
                component: darkModeControl,
                cols: 1,
                rows: 1
            };
        case "nightLight":
            return {
                component: nightLightControl,
                cols: 1,
                rows: 1
            };
        case "screenSnip":
            return {
                component: screenSnipControl,
                cols: 1,
                rows: 1
            };
        case "colorPicker":
            return {
                component: colorPickerControl,
                cols: 1,
                rows: 1
            };
        case "mic":
            return {
                component: micControl,
                cols: 1,
                rows: 1
            };
        case "idleInhibitor":
            return {
                component: idleInhibitorControl,
                cols: 1,
                rows: 1
            };
        }
        return null;
    }

    screen: screenData
    visible: open
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: columns * cellWidth + (columns - 1) * cellSpacing + sideMargin * 2
    WlrLayershell.namespace: "quickshell:macosControlCenter"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors {
        top: true
        right: true
        bottom: true
    }

    mask: Region {
        item: root.open ? grid : null
    }

    Component {
        id: networkControl
        MControlToggle {
            backdrop: backdrop
            wide: true
            settingsCommand: Config.options.apps.network
            toggleModel: NetworkToggle {
                icon: "wifi"
            }
        }
    }

    Component {
        id: bluetoothControl
        MControlToggle {
            backdrop: backdrop
            wide: true
            settingsCommand: Config.options.apps.bluetooth
            toggleModel: BluetoothToggle {
                statusText: BluetoothStatus.enabled ? Translation.tr("On") : Translation.tr("Off")
            }
        }
    }

    Component {
        id: darkModeControl
        MControlToggle {
            backdrop: backdrop
            toggleModel: DarkModeToggle {}
        }
    }

    Component {
        id: nightLightControl
        MControlToggle {
            backdrop: backdrop
            toggleModel: NightLightToggle {}
        }
    }

    Component {
        id: screenSnipControl
        MControlToggle {
            backdrop: backdrop
            toggleModel: ScreenSnipToggle {}
        }
    }

    Component {
        id: colorPickerControl
        MControlToggle {
            backdrop: backdrop
            toggleModel: ColorPickerToggle {}
        }
    }

    Component {
        id: micControl
        MControlToggle {
            backdrop: backdrop
            toggleModel: MicToggle {}
        }
    }

    Component {
        id: idleInhibitorControl
        MControlToggle {
            backdrop: backdrop
            toggleModel: IdleInhibitorToggle {}
        }
    }

    Component {
        id: mediaControl
        MControlMedia {
            backdrop: backdrop
        }
    }

    Component {
        id: volumeControl
        MControlSlider {
            backdrop: backdrop
            label: "Sound"
            settingsCommand: Config.options.apps.volumeMixer
            leadingIcon: "volume_mute"
            trailingIcon: "volume_up"
            maximum: 1
            value: Audio.sink?.audio.volume ?? 0
            onMoved: newValue => {
                if (Audio.sink?.audio)
                    Audio.sink.audio.volume = newValue;
            }
        }
    }

    Component {
        id: brightnessControl
        MControlSlider {
            backdrop: backdrop
            label: "Display"
            settingsCommand: Config.options.apps.display
            leadingIcon: "brightness_low"
            trailingIcon: "brightness_high"
            maximum: 1
            value: Brightness.getMonitorForScreen(root.screen)?.brightness ?? 0
            onMoved: newValue => Brightness.getMonitorForScreen(root.screen)?.setBrightness(newValue)
        }
    }

    Item {
        id: contentRoot
        anchors.fill: parent

        MGlassBackdrop {
            id: backdrop
            screenX: (root.screen?.width ?? 0) - root.width
            screenY: Looks.sizes.menuBarHeight
            panelWidth: root.width
            panelHeight: root.height
            captureWindows: root.open
        }

        Item {
            id: panelArea
            anchors.fill: parent
            visible: root.open

            GridLayout {
                id: grid
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: root.sideMargin
                }
                columns: root.columns
                columnSpacing: root.cellSpacing
                rowSpacing: root.cellSpacing

                Repeater {
                    model: root.controls

                    Loader {
                        required property string modelData

                        readonly property var spec: root.specFor(modelData)

                        Layout.columnSpan: spec?.cols ?? 1
                        Layout.rowSpan: spec?.rows ?? 1
                        Layout.preferredWidth: (spec?.cols ?? 1) * root.cellWidth + ((spec?.cols ?? 1) - 1) * root.cellSpacing
                        Layout.preferredHeight: (spec?.rows ?? 1) * root.cellHeight + ((spec?.rows ?? 1) - 1) * root.cellSpacing

                        active: spec !== null
                        sourceComponent: spec?.component ?? null
                    }
                }
            }
        }
    }
}
