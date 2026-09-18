//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Adjust this to make the app smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions as CF

ApplicationWindow {
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
            name: Translation.tr("Appearance"),
            icon: "palette",
            component: "modules/settings/AppearanceConfig.qml",
            keywords: ["style", "light", "dark", "theme", "colour", "color", "font", "rounding", "blur", "opacity", "animation"]
        },
        {
            name: Translation.tr("Bar"),
            icon: "toast",
            iconRotation: 180,
            component: "modules/settings/BarConfig.qml",
            keywords: ["bar", "panel", "tray", "workspaces", "clock", "top", "status"]
        },
        {
            name: Translation.tr("Panels"),
            icon: "bottom_app_bar",
            component: "modules/settings/PanelsConfig.qml",
            keywords: ["dock", "sidebar", "overview", "launcher", "osd", "popup"]
        },
        {
            name: Translation.tr("Background"),
            icon: "texture",
            component: "modules/settings/BackgroundConfig.qml",
            keywords: ["wallpaper", "desktop", "clock", "weather", "parallax"]
        },
        {
            name: Translation.tr("General"),
            icon: "browse",
            component: "modules/settings/GeneralConfig.qml",
            startsGroup: true,
            keywords: ["application", "default", "preferred", "terminal", "browser", "language", "region"]
        },
        {
            name: Translation.tr("Keyboard"),
            icon: "keyboard",
            component: "modules/settings/KeyboardConfig.qml",
            startsGroup: true,
            keywords: ["layout", "input", "source", "xkb", "shortcut", "hotkey", "compose", "character", "repeat"]
        },
        {
            name: Translation.tr("Lock screen"),
            icon: "lock",
            component: "modules/settings/LockConfig.qml",
            startsGroup: true,
            keywords: ["lock", "screen", "privacy", "security", "idle", "password"]
        },
        {
            name: Translation.tr("Capture"),
            icon: "screenshot_frame_2",
            component: "modules/settings/CaptureConfig.qml",
            keywords: ["screenshot", "recording", "screen", "snip", "region", "annotation"]
        },
        {
            name: Translation.tr("Services"),
            icon: "settings",
            component: "modules/settings/ServicesConfig.qml",
            keywords: ["service", "weather", "updates", "translation", "search", "ai"]
        },
        {
            name: Translation.tr("Advanced"),
            icon: "construction",
            component: "modules/settings/AdvancedConfig.qml",
            keywords: ["advanced", "developer", "hacks", "experimental", "policies"]
        },
        {
            name: Translation.tr("About"),
            icon: "info",
            component: "modules/settings/About.qml",
            keywords: ["device", "system", "information", "details", "hostname", "memory", "processor", "version", "os"]
        }
    ]
    property int currentPage: 0
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

    visible: true
    onClosing: Qt.quit()
    title: "illogical-impulse Settings"

    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme()
        Config.readWriteDelay = 0 // Settings app always only sets one var at a time so delay isn't needed
    }

    minimumWidth: 750
    minimumHeight: 500
    width: 1100
    height: 750
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
                anchors {
                    left: Config.options.windows.centerTitle ? undefined : parent.left
                    horizontalCenter: Config.options.windows.centerTitle ? parent.horizontalCenter : undefined
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                }
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
                    onClicked: root.close()
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
                            currentIndex: root.shownPages.indexOf(root.pages[root.currentPage])
                            expanded: navRail.expanded
                            Repeater {
                                model: root.shownPages
                                NavigationRailButton {
                                    required property var index
                                    required property var modelData
                                    readonly property int pageIndex: root.pages.indexOf(modelData)
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

                Loader {
                    id: pageLoader
                    anchors.fill: parent
                    opacity: 1.0

                    active: Config.ready
                    Component.onCompleted: {
                        source = root.pages[0].component
                    }

                    Connections {
                        target: root
                        function onCurrentPageChanged() {
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
                                value: root.pages[root.currentPage].component
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
