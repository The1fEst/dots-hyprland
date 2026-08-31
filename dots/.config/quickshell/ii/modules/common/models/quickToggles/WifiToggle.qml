import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.tr("Wi-Fi")
    statusText: !Network.wifiEnabled ? Translation.tr("Off") : Network.wifiStatus === "connected" ? (Network.active?.ssid ?? Network.networkName) : Translation.tr("Not connected")
    tooltipText: Translation.tr("%1 | Right-click to configure").arg(name)
    icon: Network.wifiSymbol

    toggled: Network.wifiEnabled
    mainAction: () => Network.toggleWifi()
    hasMenu: true
}
