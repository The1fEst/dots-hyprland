import QtQuick
import Quickshell

import qs.modules.common
import qs.modules.macos.background
import qs.modules.macos.dock
import qs.modules.macos.menuBar
import qs.modules.macos.notificationPopup
import qs.modules.macos.osd
import qs.modules.macos.polkit
import qs.modules.macos.spotlight

import qs.modules.ii.cheatsheet
import qs.modules.ii.lock
import qs.modules.ii.onScreenKeyboard
import qs.modules.ii.regionSelector
import qs.modules.ii.wallpaperSelector

Scope {
    PanelLoader { component: MacosBackground {} }
    PanelLoader { component: MacosMenuBar {} }
    PanelLoader { component: MacosDock {} }

    PanelLoader { component: Cheatsheet {} }
    PanelLoader { component: Lock {} }
    PanelLoader { component: MacosNotificationPopup {} }
    PanelLoader { component: MacosOsd {} }
    PanelLoader { component: OnScreenKeyboard {} }
    PanelLoader { component: MacosSpotlight {} }
    PanelLoader { component: MacosPolkit {} }
    PanelLoader { component: RegionSelector {} }
    PanelLoader { component: WallpaperSelector {} }
}
