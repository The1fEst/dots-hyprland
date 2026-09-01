pragma ComponentBehavior: Bound

import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.models.quickToggles
import qs.modules.macos.looks

Item {
    id: root

    required property MGlassBackdrop backdrop
    required property var screenData

    signal expandRequested(string id)

    visible: false

    function componentFor(id: string): Component {
        switch (id) {
        case "spaces":
            return spacesControl;
        case "tray":
            return trayControl;
        case "battery":
            return batteryControl;
        case "wifi":
            return wifiControl;
        case "wired":
            return wiredControl;
        case "wireGuard":
            return wireGuardControl;
        case "cloudflareWarp":
            return cloudflareWarpControl;
        case "easyEffects":
            return easyEffectsControl;
        case "powerProfile":
            return powerProfileControl;
        case "notifications":
            return notificationsControl;
        case "onScreenKeyboard":
            return onScreenKeyboardControl;
        case "bluetooth":
            return bluetoothControl;
        case "media":
            return mediaControl;
        case "volume":
            return volumeControl;
        case "brightness":
            return brightnessControl;
        case "darkMode":
            return darkModeControl;
        case "nightLight":
            return nightLightControl;
        case "screenSnip":
            return screenSnipControl;
        case "colorPicker":
            return colorPickerControl;
        case "mic":
            return micControl;
        case "idleInhibitor":
            return idleInhibitorControl;
        }
        return null;
    }

    Component {
        id: spacesControl
        MControlSpaces {
            backdrop: root.backdrop
            screenData: root.screenData
        }
    }

    Component {
        id: trayControl
        MControlTray {
            backdrop: root.backdrop
        }
    }

    Component {
        id: batteryControl
        MControlBattery {
            backdrop: root.backdrop
        }
    }

    Component {
        id: wifiControl
        MControlToggle {
            backdrop: root.backdrop
            settingsCommand: Config.options.apps.network
            toggleModel: WifiToggle {
                icon: "wifi"
            }
        }
    }

    Component {
        id: wiredControl
        MControlToggle {
            backdrop: root.backdrop
            settingsCommand: Config.options.apps.networkEthernet
            toggleModel: EthernetToggle {
                icon: "lan"
            }
        }
    }

    Component {
        id: wireGuardControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: WireGuardToggle {}
        }
    }

    Component {
        id: cloudflareWarpControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: CloudflareWarpToggle {}
        }
    }

    Component {
        id: easyEffectsControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: EasyEffectsToggle {}
        }
    }

    Component {
        id: powerProfileControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: PowerProfilesToggle {}
        }
    }

    Component {
        id: notificationsControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: NotificationToggle {}
        }
    }

    Component {
        id: onScreenKeyboardControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: OnScreenKeyboardToggle {}
        }
    }

    Component {
        id: bluetoothControl
        MControlToggle {
            backdrop: root.backdrop
            settingsCommand: Config.options.apps.bluetooth
            toggleModel: BluetoothToggle {
                statusText: BluetoothStatus.enabled ? Translation.tr("On") : Translation.tr("Off")
            }
        }
    }

    Component {
        id: darkModeControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: DarkModeToggle {}
        }
    }

    Component {
        id: nightLightControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: NightLightToggle {}
        }
    }

    Component {
        id: screenSnipControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: ScreenSnipToggle {}
        }
    }

    Component {
        id: colorPickerControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: ColorPickerToggle {}
        }
    }

    Component {
        id: micControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: MicToggle {}
        }
    }

    Component {
        id: idleInhibitorControl
        MControlToggle {
            backdrop: root.backdrop
            toggleModel: IdleInhibitorToggle {}
        }
    }

    Component {
        id: mediaControl
        MControlMedia {
            backdrop: root.backdrop
            onActivated: root.expandRequested("media")
        }
    }

    Component {
        id: volumeControl
        MControlSlider {
            backdrop: root.backdrop
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
            backdrop: root.backdrop
            label: "Display"
            settingsCommand: Config.options.apps.display
            leadingIcon: "brightness_low"
            trailingIcon: "brightness_high"
            maximum: 1
            value: Brightness.getMonitorForScreen(root.screenData)?.brightness ?? 0
            onMoved: newValue => Brightness.getMonitorForScreen(root.screenData)?.setBrightness(newValue)
        }
    }
}
