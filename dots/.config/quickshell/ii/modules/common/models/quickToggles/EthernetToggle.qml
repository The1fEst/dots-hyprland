import QtQuick
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.tr("Ethernet")
    statusText: Network.ethernet ? Translation.tr("Connected") : Translation.tr("Not connected")
    tooltipText: Translation.tr("%1 | Click to configure").arg(name)
    icon: Network.ethernet ? "lan" : "settings_ethernet"

    toggled: Network.ethernet
    mainAction: () => Quickshell.execDetached(["bash", "-c", Config.options.apps.networkEthernet])
}
