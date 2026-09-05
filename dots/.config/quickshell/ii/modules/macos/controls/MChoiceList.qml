pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.modules.macos.looks

ClippingRectangle {
    id: root

    property var options: []
    property string current: ""
    property bool available: true

    property bool previewsFamilies: false
    property string previewsStylesOf: ""

    signal selected(string value)

    function reveal(): void {
        const at = root.options.indexOf(root.current);
        if (at >= 0)
            list.positionViewAtIndex(at, ListView.Contain);
    }

    onOptionsChanged: Qt.callLater(root.reveal)
    onCurrentChanged: Qt.callLater(root.reveal)

    radius: Looks.controlRadius(Looks.control.regular)
    color: Looks.colors.quinary
    antialiasing: true

    ListView {
        id: list
        anchors.fill: parent
        anchors.margins: Looks.metrics.menu.padding
        enabled: root.available
        opacity: root.available ? 1 : 0.4
        model: root.options
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        delegate: Item {
            id: row

            required property string modelData

            readonly property bool active: row.modelData === root.current

            width: list.width
            height: Looks.metrics.menu.rowHeight

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                visible: row.active || hover.hovered
                radius: Looks.metrics.menu.highlightRadius
                color: row.active ? Looks.accent : Looks.colors.hover
                antialiasing: true
            }

            MText {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Looks.metrics.menu.highlightInset
                    rightMargin: Looks.metrics.menu.highlightInset
                    verticalCenter: parent.verticalCenter
                }
                text: row.modelData
                elide: Text.ElideRight
                color: row.active ? "#ffffff" : Looks.colors.primary
                font.family: {
                    if (root.previewsFamilies)
                        return row.modelData;
                    return root.previewsStylesOf.length > 0 ? root.previewsStylesOf : Looks.font.text;
                }
                font.styleName: root.previewsStylesOf.length > 0 ? row.modelData : Looks.font.rendered(Looks.font.style.body.styleName)
            }

            HoverHandler {
                id: hover
                cursorShape: Qt.PointingHandCursor
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.selected(row.modelData)
            }
        }
    }
}
