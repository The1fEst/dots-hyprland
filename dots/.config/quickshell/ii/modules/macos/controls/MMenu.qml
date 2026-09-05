pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import qs.modules.macos.looks

// An in-window menu. The menu bar's own is a layer-shell surface, which a plain
// application window cannot put one of over its content.
Popup {
    id: root

    // Each entry is { label, checked?, separator?, run? }.
    property list<var> entries: []

    property real minimumWidth: 200
    property real maximumWidth: 420

    readonly property real labelInset: 24 + 8
    readonly property real labelsWidth: {
        let widest = 0;
        for (const entry of root.entries)
            widest = Math.max(widest, measure.advanceWidth(entry.label ?? ""));
        return widest;
    }

    FontMetrics {
        id: measure
        font.family: Looks.font.text
        font.pixelSize: Looks.font.style.body.size
    }

    signal activated(var entry)

    leftPadding: Looks.metrics.menu.highlightInset
    rightPadding: Looks.metrics.menu.highlightInset
    topPadding: Looks.metrics.menu.padding
    bottomPadding: Looks.metrics.menu.padding
    width: Math.min(root.maximumWidth, Math.max(root.minimumWidth, root.labelsWidth + root.labelInset + root.leftPadding + root.rightPadding))
    modal: true
    dim: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        radius: Looks.radius.normal
        color: Looks.surfaces.panel
        border.width: 1
        border.color: Looks.colors.quinary
        antialiasing: true
    }

    contentItem: Column {
        spacing: 0

        Repeater {
            model: root.entries

            Item {
                id: row

                required property var modelData

                readonly property bool separator: row.modelData.separator ?? false

                width: parent.width
                implicitHeight: row.separator ? Looks.metrics.menu.separatorRowHeight : Looks.metrics.menu.rowHeightLarge

                Rectangle {
                    anchors.fill: parent
                    visible: !row.separator && hover.containsMouse
                    radius: Looks.metrics.menu.highlightRadius
                    color: Looks.accent
                    antialiasing: true
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: Looks.metrics.menu.highlightInset
                        rightMargin: Looks.metrics.menu.highlightInset
                    }
                    visible: row.separator
                    height: Looks.metrics.menu.separatorHeight
                    color: Looks.colors.quaternary
                }

                MSymbol {
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    visible: row.modelData.checked ?? false
                    symbol: "checkmark"
                    height: Looks.control.glyph.tick
                    color: hover.containsMouse ? "#ffffff" : Looks.colors.primary
                }

                MText {
                    anchors {
                        left: parent.left
                        leftMargin: 24
                        right: parent.right
                        rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    visible: !row.separator
                    text: row.modelData.label ?? ""
                    elide: Text.ElideRight
                    color: hover.containsMouse ? "#ffffff" : Looks.colors.primary
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    enabled: !row.separator
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.close();
                        root.activated(row.modelData);
                    }
                }
            }
        }
    }
}
