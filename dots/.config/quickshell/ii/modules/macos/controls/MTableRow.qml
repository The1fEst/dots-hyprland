pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Rectangle {
    id: root

    property string label: ""
    property string detail: ""
    property bool header: false
    property bool selected: false
    property bool separator: true

    readonly property int inset: 20
    readonly property int detailColumn: 250

    signal clicked

    implicitWidth: parent?.width ?? 0
    implicitHeight: 26
    color: root.selected ? Looks.colors.tertiary : "transparent"

    MText {
        anchors {
            left: parent.left
            right: detail.visible ? detail.left : parent.right
            leftMargin: root.inset
            rightMargin: Looks.settings.formRowInset
            verticalCenter: parent.verticalCenter
        }
        text: root.label
        elide: Text.ElideRight
        color: root.header ? Looks.colors.secondary : Looks.colors.primary
    }

    MText {
        id: detail
        anchors {
            left: parent.left
            leftMargin: root.detailColumn
            verticalCenter: parent.verticalCenter
        }
        visible: root.detail.length > 0
        text: root.detail
        color: root.header ? Looks.colors.secondary : Looks.colors.primary
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: root.inset
        }
        visible: root.separator && !root.selected
        height: 1
        color: Looks.colors.divider
    }

    MouseArea {
        anchors.fill: parent
        enabled: !root.header
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
