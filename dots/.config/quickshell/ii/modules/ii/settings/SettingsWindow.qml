import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions as CF

FloatingWindow {
    id: root
    property string firstRunFilePath: CF.FileUtils.trimFileProtocol(`${Directories.state}/user/first_run.txt`)
    property string firstRunFileContent: "This file is just here to confirm you've been greeted :>"
    property real contentPadding: 8
    property bool showNextTime: false
    property var pages: [
        {
            name: Translation.tr("Quick"),
            icon: "instant_mix",
            component: "modules/settings/QuickConfig.qml",
            keywords: ["quick", "common", "frequent"]
        },
        {
            name: Translation.tr("Wi-Fi"),
            icon: "wifi",
            component: "modules/settings/WifiConfig.qml",
            startsGroup: true,
            keywords: ["wifi", "wireless", "network", "internet", "connection", "password"]
        },
        {
            name: Translation.tr("Network"),
            icon: "lan",
            component: "modules/settings/NetworkConfig.qml",
            keywords: ["network", "ethernet", "wired", "vpn", "wireguard", "connection", "proxy"]
        },
        {
            name: Translation.tr("Bluetooth"),
            icon: "bluetooth",
            component: "modules/settings/BluetoothConfig.qml",
            keywords: ["bluetooth", "pair", "device", "headset", "mouse", "keyboard", "wireless"]
        },
        {
            name: Translation.tr("Displays"),
            icon: "monitor",
            component: "modules/settings/DisplaysConfig.qml",
            startsGroup: true,
            keywords: ["screen", "resolution", "refresh", "monitor", "night", "light", "hdr", "scale", "arrange", "vrr"]
        },
        {
            name: Translation.tr("Sound"),
            icon: "volume_up",
            component: "modules/settings/SoundConfig.qml",
            keywords: ["card", "microphone", "volume", "balance", "headset", "audio", "output", "input"]
        },
        {
            name: Translation.tr("Power"),
            icon: "battery_android_full",
            component: "modules/settings/PowerConfig.qml",
            keywords: ["power", "sleep", "suspend", "battery", "blank", "idle", "dpms", "energy", "lock"]
        },
        {
            name: Translation.tr("Multitasking"),
            icon: "select_window_2",
            component: "modules/settings/MultitaskingConfig.qml",
            keywords: ["workspace", "tiling", "layout", "gaps", "snap", "gesture", "swipe", "overview", "window"]
        },
        {
            name: Translation.tr("Appearance"),
            icon: "palette",
            component: "modules/settings/AppearanceConfig.qml",
            keywords: ["style", "light", "dark", "theme", "colour", "color", "font", "rounding", "blur", "opacity", "animation", "wallpaper", "background", "bar", "panel", "dock", "sidebar"]
        },
        {
            name: Translation.tr("Apps"),
            icon: "apps",
            component: "modules/settings/AppsConfig.qml",
            startsGroup: true,
            keywords: ["application", "default", "preferred", "terminal", "browser", "open", "with", "handler"]
        },
        {
            name: Translation.tr("Notifications"),
            icon: "notifications",
            component: "modules/settings/NotificationsConfig.qml",
            keywords: ["notification", "banner", "message", "popup", "disturb", "osd"]
        },
        {
            name: Translation.tr("Search"),
            icon: "search",
            component: "modules/settings/SearchConfig.qml",
            keywords: ["search", "find", "launcher", "prefix", "results", "fuzzy"]
        },
        {
            name: Translation.tr("Mouse & Touchpad"),
            icon: "mouse",
            component: "modules/settings/MouseConfig.qml",
            startsGroup: true,
            keywords: ["trackpad", "touchpad", "pointer", "click", "tap", "button", "scroll", "cursor", "sensitivity"]
        },
        {
            name: Translation.tr("Keyboard"),
            icon: "keyboard",
            component: "modules/settings/KeyboardConfig.qml",
            keywords: ["layout", "input", "source", "xkb", "shortcut", "hotkey", "compose", "character", "repeat"]
        },
        {
            name: Translation.tr("Accessibility"),
            icon: "accessibility_new",
            component: "modules/settings/AccessibilityConfig.qml",
            startsGroup: true,
            keywords: ["accessibility", "a11y", "zoom", "magnifier", "cursor", "size", "animation", "motion", "repeat", "contrast"]
        },
        {
            name: Translation.tr("Privacy & Security"),
            icon: "lock",
            component: "modules/settings/PrivacyConfig.qml",
            keywords: ["privacy", "security", "lock", "screen", "screenshot", "recording", "camera", "microphone", "clipboard", "safety"]
        },
        {
            name: Translation.tr("System"),
            icon: "settings_applications",
            component: "modules/settings/SystemConfig.qml",
            keywords: ["system", "about", "device", "information", "hostname", "memory", "processor", "version", "os", "language", "region", "time", "date", "user", "account", "services", "advanced"]
        }
    ]
    property int currentPage: 0
    property var subpage: null
    readonly property string shownComponent: root.subpage ? root.subpage.component : (root.pages[root.currentPage]?.component ?? root.pages[0].component)
    readonly property url shownSource: Qt.resolvedUrl(Quickshell.shellPath(root.shownComponent))

    Connections {
        target: GlobalStates
        function onSettingsPageChanged() {
            const index = root.pageIndexOf(GlobalStates.settingsPage);
            if (index === -1)
                return;
            root.subpage = null;
            root.currentPage = index;
        }
    }

    IpcHandler {
        target: "settings"

        function open(): void {
            GlobalStates.settingsOpen = true;
        }

        function openPage(page: string): void {
            GlobalStates.settingsPage = page;
            GlobalStates.settingsOpen = true;
        }

        function close(): void {
            GlobalStates.settingsOpen = false;
        }

        function toggle(): void {
            GlobalStates.settingsOpen = !GlobalStates.settingsOpen;
        }
    }

    function pageIndexOf(component: string): int {
        return root.pages.findIndex(page => page.component === component);
    }
    onCurrentPageChanged: root.subpage = null
    property string pageQuery: ""
    readonly property bool searching: root.pageQuery.trim().length > 0
    readonly property var shownPages: {
        if (!root.searching)
            return root.pages;
        const terms = root.pageQuery.toLowerCase().split(/\s+/).filter(term => term.length > 0);
        const named = page => terms.every(term => page.name.toLowerCase().includes(term));
        const known = page => {
            const haystack = `${page.name} ${(page.keywords ?? []).join(" ")}`.toLowerCase();
            return terms.every(term => haystack.includes(term));
        };
        return root.pages.filter(known).sort((a, b) => named(b) - named(a));
    }

    visible: GlobalStates.settingsOpen
    onClosed: GlobalStates.settingsOpen = false
    title: "illogical-impulse Settings"

    minimumSize: Qt.size(750, 500)
    implicitWidth: 1100
    implicitHeight: 750
    color: Appearance.m3colors.m3background

    ColumnLayout {
        anchors {
            fill: parent
            margins: contentPadding
        }

        Keys.onPressed: (event) => {
            if (event.modifiers === Qt.ControlModifier) {
                if (event.key === Qt.Key_PageDown) {
                    root.currentPage = Math.min(root.currentPage + 1, root.pages.length - 1)
                    event.accepted = true;
                } 
                else if (event.key === Qt.Key_PageUp) {
                    root.currentPage = Math.max(root.currentPage - 1, 0)
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Tab) {
                    root.currentPage = (root.currentPage + 1) % root.pages.length;
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Backtab) {
                    root.currentPage = (root.currentPage - 1 + root.pages.length) % root.pages.length;
                    event.accepted = true;
                }
            }
        }

        Item { // Titlebar
            visible: Config.options?.windows.showTitlebar
            Layout.fillWidth: true
            Layout.fillHeight: false
            implicitHeight: Math.max(titleText.implicitHeight, windowControlsRow.implicitHeight)
            StyledText {
                id: titleText
                anchors.verticalCenter: parent.verticalCenter
                x: Config.options.windows.centerTitle ? (parent.width - width) / 2 : 12
                color: Appearance.colors.colOnLayer0
                text: Translation.tr("Settings")
                font {
                    family: Appearance.font.family.title
                    pixelSize: Appearance.font.pixelSize.title
                    variableAxes: Appearance.font.variableAxes.title
                }
            }
            RowLayout { // Window controls row
                id: windowControlsRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                RippleButton {
                    buttonRadius: Appearance.rounding.full
                    implicitWidth: 35
                    implicitHeight: 35
                    onClicked: GlobalStates.settingsOpen = false
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "close"
                        iconSize: 20
                    }
                }
            }
        }

        RowLayout { // Window content with navigation rail and content pane
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: contentPadding
            Item {
                id: navRailWrapper
                Layout.fillHeight: true
                Layout.margins: 5
                implicitWidth: navRail.expanded ? Math.min(230, Math.max(150, tabArray.implicitWidth)) : fab.baseSize
                Behavior on implicitWidth {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                NavigationRail { // Window content with navigation rail and content pane
                    id: navRail
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    spacing: 10
                    expanded: root.width > 900
                    
                    NavigationRailExpandButton {
                        focus: root.visible
                    }

                    FloatingActionButton {
                        id: fab
                        property bool justCopied: false
                        iconText: justCopied ? "check" : "edit"
                        buttonText: justCopied ? Translation.tr("Path copied") : Translation.tr("Config file")
                        expanded: navRail.expanded
                        downAction: () => {
                            Qt.openUrlExternally(`${Directories.config}/illogical-impulse/config.json`);
                        }
                        altAction: () => {
                            Quickshell.clipboardText = CF.FileUtils.trimFileProtocol(`${Directories.config}/illogical-impulse/config.json`);
                            fab.justCopied = true;
                            revertTextTimer.restart()
                        }

                        Timer {
                            id: revertTextTimer
                            interval: 1500
                            onTriggered: {
                                fab.justCopied = false;
                            }
                        }

                        StyledToolTip {
                            text: Translation.tr("Open the shell config file\nAlternatively right-click to copy path")
                        }
                    }

                    MaterialTextField {
                        id: pageSearch
                        Layout.fillWidth: true
                        Layout.leftMargin: 4
                        Layout.rightMargin: 4
                        visible: navRail.expanded
                        placeholderText: Translation.tr("Search")
                        onTextChanged: root.pageQuery = text
                        onVisibleChanged: if (!visible) text = ""
                    }

                    StyledFlickable {
                        id: navRailScroll
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentHeight: tabArray.implicitHeight
                        clip: true

                        function revealCurrentPage(): void {
                            const item = tabArray.currentItem;
                            if (!item)
                                return;
                            const top = item.y - (item.startsGroup ? item.groupSpacing : 0);
                            const bottom = item.y + item.height;
                            if (top < navRailScroll.contentY)
                                navRailScroll.contentY = top;
                            else if (bottom > navRailScroll.contentY + navRailScroll.height)
                                navRailScroll.contentY = bottom - navRailScroll.height;
                        }

                        Connections {
                            target: root
                            function onCurrentPageChanged() {
                                navRailScroll.revealCurrentPage();
                            }
                        }

                        NavigationRailTabArray {
                            id: tabArray
                            width: navRailScroll.width
                            height: implicitHeight
                            currentIndex: root.shownPages.findIndex(page => page.component === root.pages[root.currentPage]?.component)
                            expanded: navRail.expanded
                            Repeater {
                                model: root.shownPages
                                NavigationRailButton {
                                    required property var index
                                    required property var modelData
                                    readonly property int pageIndex: root.pageIndexOf(modelData.component)
                                    toggled: root.currentPage === pageIndex
                                    onPressed: root.currentPage = pageIndex;
                                    expanded: navRail.expanded
                                    buttonIcon: modelData.icon
                                    buttonIconRotation: modelData.iconRotation || 0
                                    buttonText: modelData.name
                                    startsGroup: root.searching ? false : (modelData.startsGroup ?? false)
                                    showLabel: navRail.expanded
                                    showToggledHighlight: false

                                    StyledToolTip {
                                        extraVisibleCondition: !navRail.expanded
                                        text: modelData.name
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Rectangle { // Content container
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.m3colors.m3surfaceContainerLow
                radius: Appearance.rounding.windowRounding - root.contentPadding

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        id: subpageHeader

                        visible: root.subpage !== null
                        Layout.fillWidth: true
                        Layout.margins: 10
                        spacing: 8

                        RippleButton {
                            buttonRadius: Appearance.rounding.full
                            implicitWidth: 35
                            implicitHeight: 35
                            onClicked: root.subpage = null
                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                text: "arrow_back"
                                iconSize: 20
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: root.subpage?.name ?? ""
                            font.pixelSize: Appearance.font.pixelSize.larger
                            color: Appearance.colors.colOnLayer1
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Loader {
                            id: pageLoader
                            anchors.fill: parent
                            opacity: 1.0

                            active: Config.ready
                            Component.onCompleted: {
                                source = root.shownSource
                            }

                            Connections {
                                target: pageLoader.item
                                function onSubpageRequested(name, component) {
                                    root.subpage = {
                                        name: name,
                                        component: component
                                    };
                                }
                            }

                            Connections {
                                target: root
                                function onShownComponentChanged() {
                                    switchAnim.complete();
                                    switchAnim.start();
                                }
                            }

                            SequentialAnimation {
                                id: switchAnim

                                NumberAnimation {
                                    target: pageLoader
                                    properties: "opacity"
                                    from: 1
                                    to: 0
                                    duration: 100
                                    easing.type: Appearance.animation.elementMoveExit.type
                                    easing.bezierCurve: Appearance.animationCurves.emphasizedFirstHalf
                                }
                                ParallelAnimation {
                                    PropertyAction {
                                        target: pageLoader
                                        property: "source"
                                        value: root.shownSource
                                    }
                                    PropertyAction {
                                        target: pageLoader
                                        property: "anchors.topMargin"
                                        value: 20
                                    }
                                }
                                ParallelAnimation {
                                    NumberAnimation {
                                        target: pageLoader
                                        properties: "opacity"
                                        from: 0
                                        to: 1
                                        duration: 200
                                        easing.type: Appearance.animation.elementMoveEnter.type
                                        easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                                    }
                                    NumberAnimation {
                                        target: pageLoader
                                        properties: "anchors.topMargin"
                                        to: 0
                                        duration: 200
                                        easing.type: Appearance.animation.elementMoveEnter.type
                                        easing.bezierCurve: Appearance.animationCurves.emphasizedLastHalf
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
