import QtQuick
import Quickshell

import qs.modules.common
import qs.modules.macos.background
import qs.modules.macos.dock
import qs.modules.macos.menuBar
import qs.modules.macos.notificationPopup

import qs.modules.ii.cheatsheet
import qs.modules.ii.lock
import qs.modules.ii.mediaControls
import qs.modules.ii.onScreenDisplay
import qs.modules.ii.onScreenKeyboard
import qs.modules.ii.overview
import qs.modules.ii.polkit
import qs.modules.ii.regionSelector
import qs.modules.ii.sessionScreen
import qs.modules.ii.sidebarRight
import qs.modules.ii.wallpaperSelector

Scope {
    PanelLoader { component: MacosBackground {} }
    PanelLoader { component: MacosMenuBar {} }
    PanelLoader { component: MacosDock {} }

    PanelLoader { component: Cheatsheet {} }
    PanelLoader { component: Lock {} }
    PanelLoader { component: MediaControls {} }
    PanelLoader { component: MacosNotificationPopup {} }
    PanelLoader { component: OnScreenDisplay {} }
    PanelLoader { component: OnScreenKeyboard {} }
    PanelLoader { component: Overview {} }
    PanelLoader { component: Polkit {} }
    PanelLoader { component: RegionSelector {} }
    PanelLoader { component: SessionScreen {} }
    PanelLoader { component: SidebarRight {} }
    PanelLoader { component: WallpaperSelector {} }
}
