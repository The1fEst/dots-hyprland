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
    property real menuWidth: 200

    signal activated(var entry)

    padding: 5
    width: root.menuWidth
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
                implicitHeight: row.separator ? 11 : Looks.metrics.menu.rowHeightLarge

                Rectangle {
                    anchors.fill: parent
                    visible: !row.separator && hover.containsMouse
                    radius: Looks.radius.small
                    color: Looks.accent
                    antialiasing: true
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 9
                        rightMargin: 9
                    }
                    visible: row.separator
                    height: 1
                    color: Looks.colors.divider
                }

                MSymbol {
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    visible: row.modelData.checked ?? false
                    symbol: "checkmark"
                    symbolSize: 11
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
