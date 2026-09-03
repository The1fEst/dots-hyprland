//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// System Settings for the macos family. Separate from settings.qml, which configures the
// shell itself — this one drives the machine: displays, sound, network.

import QtQuick
import QtQuick.Controls
import qs.modules.macos.looks
import qs.modules.macos.settings

ApplicationWindow {
    id: root

    minimumWidth: 740
    minimumHeight: 560
    width: 740
    height: 932
    visible: true
    title: qsTr("System Settings")
    color: Looks.dark ? "#1e1e20" : "#f6f6f6"

    onClosing: Qt.quit()

    MSettingsWindow {
        anchors.fill: parent
    }
}
