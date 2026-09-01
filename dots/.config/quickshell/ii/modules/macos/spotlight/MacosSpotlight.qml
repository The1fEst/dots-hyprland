pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.macos.looks

Scope {
    id: root

    property bool dontAutoCancelSearch: false

    function toggleWithPrefix(prefix: string): void {
        if (GlobalStates.overviewOpen && root.dontAutoCancelSearch) {
            GlobalStates.overviewOpen = false;
            return;
        }
        root.dontAutoCancelSearch = true;
        win.preset(prefix);
        GlobalStates.overviewOpen = true;
    }

    PanelWindow {
        id: win

        readonly property real cardWidth: 680
        readonly property int resultLimit: 20
        readonly property var entries: LauncherSearch.results.slice(0, win.resultLimit)
        readonly property bool showResults: field.query.length > 0

        function preset(prefix: string): void {
            field.mode = prefix;
            field.text = "";
            field.focusInput();
        }

        function activate(index: int): void {
            const entry = win.entries[index];
            if (!entry)
                return;
            GlobalStates.overviewOpen = false;
            entry.execute();
        }

        function removeEntry(index: int): void {
            const entry = win.entries[index];
            if (!entry)
                return;
            for (const action of entry.actions ?? []) {
                if (action.iconName !== "delete")
                    continue;
                action.execute();
                return;
            }
        }

        function complete(index: int): void {
            const entry = win.entries[index];
            if (!entry)
                return;
            field.text = entry.name;
            field.focusInput();
            field.input.cursorPosition = field.text.length;
        }

        function move(delta: int): void {
            if (win.entries.length === 0)
                return;
            const next = list.currentIndex + delta;
            list.currentIndex = Math.max(0, Math.min(win.entries.length - 1, next));
            list.positionViewAtIndex(list.currentIndex, ListView.Contain);
        }

        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
        visible: GlobalStates.overviewOpen
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.namespace: "quickshell:macosSpotlight"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: GlobalStates.overviewOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        mask: Region {
            item: GlobalStates.overviewOpen ? card : null
        }

        Binding {
            target: LauncherSearch
            property: "query"
            value: field.query
        }

        Connections {
            target: GlobalStates

            function onOverviewOpenChanged() {
                if (!GlobalStates.overviewOpen) {
                    root.dontAutoCancelSearch = false;
                    GlobalFocusGrab.dismiss();
                    return;
                }
                if (!root.dontAutoCancelSearch)
                    field.clear();
                field.focusInput();
                list.currentIndex = 0;
                GlobalFocusGrab.addDismissable(win);
            }
        }

        Connections {
            target: GlobalFocusGrab

            function onDismissed() {
                GlobalStates.overviewOpen = false;
            }
        }

        MGlassBackdrop {
            id: backdrop
            screenY: Looks.sizes.menuBarHeight
            panelWidth: win.width
            panelHeight: win.height
            captureWindows: win.visible
        }

        MGlass {
            id: card
            backdrop: backdrop
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: Math.round(win.height * 0.18)
            }
            width: win.cardWidth
            implicitHeight: field.implicitHeight + (win.showResults ? separator.height + list.height : 0)
            opacity: GlobalStates.overviewOpen ? 1 : 0
            scale: GlobalStates.overviewOpen ? 1 : 0.96

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: Looks.animation.fast
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Looks.animation.fast
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Looks.animation.fast
                    easing.type: Easing.OutCubic
                }
            }

            MSpotlightField {
                id: field
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                onAccepted: win.activate(list.currentIndex)
                onMoved: delta => win.move(delta)
                onCompleted: win.complete(list.currentIndex)
                onRemoved: win.removeEntry(list.currentIndex)
                onDismissed: GlobalStates.overviewOpen = false
            }

            Rectangle {
                id: separator
                anchors {
                    left: parent.left
                    right: parent.right
                    top: field.bottom
                }
                visible: win.showResults
                height: 1
                color: Looks.colors.divider
            }

            ListView {
                id: list
                anchors {
                    left: parent.left
                    right: parent.right
                    top: separator.bottom
                }
                visible: win.showResults
                height: Math.min(420, list.contentHeight + list.topMargin + list.bottomMargin)
                topMargin: 10
                bottomMargin: 14
                clip: true
                interactive: true
                highlightMoveDuration: 0
                model: win.entries

                onCountChanged: list.currentIndex = 0

                delegate: MSpotlightRow {
                    required property var modelData
                    required property int index

                    width: list.width
                    entry: modelData
                    selected: list.currentIndex === index
                    onEntered: list.currentIndex = index
                    onActivated: win.activate(index)
                }
            }

            MText {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: separator.bottom
                    topMargin: 16
                }
                visible: win.showResults && win.entries.length === 0
                horizontalAlignment: Text.AlignHCenter
                text: Translation.tr("No Results")
                font.pixelSize: Looks.font.size.large
                color: Looks.colors.secondary
            }
        }
    }

    IpcHandler {
        target: "search"

        function toggle(): void {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
        function workspacesToggle(): void {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
        function close(): void {
            GlobalStates.overviewOpen = false;
        }
        function open(): void {
            GlobalStates.overviewOpen = true;
        }
        function toggleReleaseInterrupt(): void {
            GlobalStates.superReleaseMightTrigger = false;
        }
        function clipboardToggle(): void {
            root.toggleWithPrefix(Config.options.search.prefix.clipboard);
        }
    }

    GlobalShortcut {
        name: "searchToggle"
        description: "Toggles search on press"

        onPressed: GlobalStates.overviewOpen = !GlobalStates.overviewOpen
    }

    GlobalShortcut {
        name: "overviewWorkspacesClose"
        description: "Closes search on press"

        onPressed: GlobalStates.overviewOpen = false
    }

    GlobalShortcut {
        name: "overviewWorkspacesToggle"
        description: "Toggles search on press"

        onPressed: GlobalStates.overviewOpen = !GlobalStates.overviewOpen
    }

    GlobalShortcut {
        name: "searchToggleRelease"
        description: "Toggles search on release"

        onPressed: GlobalStates.superReleaseMightTrigger = true

        onReleased: {
            if (!GlobalStates.superReleaseMightTrigger) {
                GlobalStates.superReleaseMightTrigger = true;
                return;
            }
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
    }

    GlobalShortcut {
        name: "searchToggleReleaseInterrupt"
        description: "Interrupts possibility of search being toggled on release"

        onPressed: GlobalStates.superReleaseMightTrigger = false
    }

    GlobalShortcut {
        name: "overviewClipboardToggle"
        description: "Opens search with the clipboard prefix"

        onPressed: root.toggleWithPrefix(Config.options.search.prefix.clipboard)
    }

    GlobalShortcut {
        name: "overviewEmojiToggle"
        description: "Opens search with the emoji prefix"

        onPressed: root.toggleWithPrefix(Config.options.search.prefix.emojis)
    }
}
