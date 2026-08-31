pragma ComponentBehavior: Bound

import QtQuick
import qs.services
import qs.modules.common.widgets
import qs.modules.macos.items
import qs.modules.macos.looks

MGlass {
    id: root

    property string itemId: ""
    property string current: ""
    property bool opened: false

    signal chosen(string size)

    readonly property var options: MItems.sizeOptions(MItems.info(root.itemId))

    function labelFor(size: string): string {
        if (size === "small")
            return Translation.tr("Small");
        if (size === "large")
            return Translation.tr("Large");
        return Translation.tr("Normal");
    }

    function open(id: string, size: string, position: point) {
        root.itemId = id;
        root.current = size;
        root.x = Math.max(6, Math.min(position.x, root.parent.width - root.width - 6));
        root.y = Math.max(6, Math.min(position.y, root.parent.height - root.height - 6));
        root.opened = true;
    }

    visible: root.opened
    z: 50
    radius: 12
    implicitWidth: 148
    implicitHeight: rows.implicitHeight + 12

    Column {
        id: rows
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 6
        }

        Repeater {
            model: root.options

            Rectangle {
                id: row
                required property string modelData

                width: rows.width
                height: 30
                radius: 8
                color: rowArea.containsMouse ? Looks.colors.hover : "transparent"

                MaterialSymbol {
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    text: "check"
                    iconSize: 15
                    color: Looks.accent
                    opacity: root.current === row.modelData ? 1 : 0
                }

                MText {
                    anchors {
                        left: parent.left
                        leftMargin: 31
                        verticalCenter: parent.verticalCenter
                    }
                    text: root.labelFor(row.modelData)
                    color: Looks.colors.primary
                }

                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.opened = false;
                        root.chosen(row.modelData);
                    }
                }
            }
        }
    }
}
