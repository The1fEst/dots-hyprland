pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common

Singleton {
    id: root

    readonly property string wifiNow: Network.wifiEnabled && Network.wifiStatus === "connected" ? root.wifi : root.wifiOff
    readonly property string batteryNow: Battery.available ? (Battery.isCharging ? root.batteryCharging : root.battery) : root.batteryUnknown
    readonly property string volumeNow: Audio.sink?.audio?.muted ? root.volumeMuted : root.volume
    readonly property string microphoneNow: Audio.source?.audio?.muted ? root.microphoneMuted : root.microphone
    readonly property string notificationsNow: Notifications.silent ? root.notificationsPaused : root.notifications
    readonly property string keyboardNow: GlobalStates.oskOpen ? root.keyboardHide : root.keyboard
    readonly property string nightLightNow: Config.options.light.night.automatic ? root.nightLightAuto : root.nightLight
    readonly property string powerProfileNow: switch (PowerProfiles.profile) {
    case PowerProfile.PowerSaver:
        return root.powerSaver;
    case PowerProfile.Performance:
        return root.powerPerformance;
    default:
        return root.powerBalanced;
    }

    readonly property string controlCentre: "switch.2"
    readonly property string search: "magnifyingglass"
    readonly property string checkmark: "checkmark"
    readonly property string close: "xmark"
    readonly property string collapse: "chevron.up"
    readonly property string chevronRight: "chevron.right"
    readonly property string chevronLeft: "chevron.left"
    readonly property string send: "arrow.up"
    readonly property string language: "globe"
    readonly property string edit: "pencil"

    readonly property string battery: "battery.100percent"
    readonly property string batteryCharging: "battery.100percent.bolt"
    readonly property string batteryUnknown: "battery.0percent"

    readonly property string brightness: "sun.max.fill"
    readonly property string brightnessLow: "sun.min.fill"

    readonly property string music: "music.note"
    readonly property string nowPlaying: "play.circle"
    readonly property string playing: "waveform"
    readonly property string play: "play.fill"
    readonly property string pause: "pause.fill"
    readonly property string previous: "backward.fill"
    readonly property string next: "forward.fill"

    readonly property string volume: "speaker.wave.3.fill"
    readonly property string volumeLow: "speaker.fill"
    readonly property string volumeMuted: "speaker.slash.fill"

    readonly property string wifi: "wifi"
    readonly property string wifiOff: "wifi.slash"
    readonly property string wired: "network"
    readonly property string bluetooth: "bluetooth"
    readonly property string vpn: "key.fill"
    readonly property string secureTunnel: "lock.shield"

    readonly property string audioEffects: "waveform"
    readonly property string microphone: "microphone"
    readonly property string microphoneMuted: "microphone.slash"

    readonly property string notifications: "bell.fill"
    readonly property string notificationsPaused: "bell.slash.fill"

    readonly property string keyboard: "keyboard"
    readonly property string keyboardHide: "keyboard.chevron.compact.down"

    readonly property string darkMode: "circle.lefthalf.filled"
    readonly property string nightLight: "moon.fill"
    readonly property string nightLightAuto: "moon.stars.fill"

    readonly property string powerSaver: "leaf.fill"
    readonly property string powerBalanced: "wind"
    readonly property string powerPerformance: "flame.fill"

    readonly property string spaces: "square.grid.2x2"
    readonly property string tray: "menubar.rectangle"

    readonly property string screenSnip: "camera.viewfinder"
    readonly property string colourPicker: "eyedropper"
    readonly property string idleInhibitor: "cup.and.saucer.fill"
}
