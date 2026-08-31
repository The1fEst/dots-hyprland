pragma ComponentBehavior: Bound

import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.macos.looks

Item {
    id: root

    property string mode: ""
    property alias text: input.text
    property alias input: input
    readonly property string query: root.mode + input.text

    signal accepted
    signal moved(int delta)
    signal dismissed
    signal completed
    signal removed

    implicitHeight: 62

    function focusInput(): void {
        input.forceActiveFocus();
        input.selectAll();
    }

    function clear(): void {
        input.text = "";
        root.mode = "";
    }

    function modeLabel(prefix: string): string {
        const prefixes = Config.options.search.prefix;
        switch (prefix) {
        case prefixes.clipboard:
            return Translation.tr("Clipboard");
        case prefixes.emojis:
            return Translation.tr("Emoji");
        case prefixes.math:
            return Translation.tr("Calculate");
        case prefixes.shellCommand:
            return Translation.tr("Run");
        case prefixes.action:
            return Translation.tr("Action");
        case prefixes.app:
            return Translation.tr("Apps");
        }
        return "";
    }

    function modeIcon(prefix: string): string {
        const prefixes = Config.options.search.prefix;
        switch (prefix) {
        case prefixes.clipboard:
            return "content_paste";
        case prefixes.emojis:
            return "mood";
        case prefixes.math:
            return "calculate";
        case prefixes.shellCommand:
            return "terminal";
        case prefixes.action:
            return "bolt";
        case prefixes.app:
            return "apps";
        }
        return "search";
    }

    function modePlaceholder(prefix: string): string {
        const prefixes = Config.options.search.prefix;
        switch (prefix) {
        case prefixes.clipboard:
            return Translation.tr("Clipboard history");
        case prefixes.emojis:
            return Translation.tr("Search emoji");
        case prefixes.math:
            return Translation.tr("Type an expression");
        case prefixes.shellCommand:
            return Translation.tr("Type a command");
        case prefixes.action:
            return Translation.tr("Pick an action");
        case prefixes.app:
            return Translation.tr("Search apps");
        }
        return Translation.tr("Spotlight Search");
    }

    MaterialSymbol {
        id: glyph
        anchors {
            left: parent.left
            leftMargin: 22
            verticalCenter: parent.verticalCenter
        }
        text: root.modeIcon(root.mode)
        iconSize: 26
        color: Looks.colors.secondary
    }

    Rectangle {
        id: token
        anchors {
            left: glyph.right
            leftMargin: root.mode.length > 0 ? 14 : 0
            verticalCenter: parent.verticalCenter
        }
        visible: root.mode.length > 0
        width: root.mode.length > 0 ? tokenLabel.implicitWidth + 20 : 0
        height: 26
        radius: height / 2
        color: Looks.accent
        antialiasing: true

        MText {
            id: tokenLabel
            anchors.centerIn: parent
            text: root.modeLabel(root.mode)
            font.pixelSize: Looks.font.size.normal
            emphasized: true
            color: "#ffffff"
        }
    }

    TextInput {
        id: input
        anchors {
            left: token.right
            leftMargin: 14
            right: parent.right
            rightMargin: 22
            verticalCenter: parent.verticalCenter
        }
        font.family: Looks.font.display
        font.pixelSize: 22
        color: Looks.colors.primary
        selectionColor: Looks.accent
        selectedTextColor: "#ffffff"
        selectByMouse: true
        clip: true

        onTextChanged: {
            const prefixes = Config.options.search.prefix;
            for (const prefix of [prefixes.action, prefixes.app, prefixes.clipboard, prefixes.emojis, prefixes.math, prefixes.shellCommand]) {
                if (!input.text.startsWith(prefix))
                    continue;
                root.mode = prefix;
                input.text = input.text.slice(prefix.length);
                return;
            }
        }

        onAccepted: root.accepted()

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.dismissed();
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                root.moved(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                root.moved(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Tab) {
                root.completed();
                event.accepted = true;
            } else if (event.key === Qt.Key_Delete && (event.modifiers & Qt.ShiftModifier)) {
                root.removed();
                event.accepted = true;
            } else if (event.key === Qt.Key_Backspace && input.text.length === 0 && root.mode.length > 0) {
                root.mode = "";
                event.accepted = true;
            }
        }

        MText {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            visible: input.text.length === 0
            text: root.modePlaceholder(root.mode)
            font.family: Looks.font.display
            font.pixelSize: 22
            color: Looks.colors.tertiary
        }
    }
}
