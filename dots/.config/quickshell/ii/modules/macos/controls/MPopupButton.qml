pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Item {
    id: root

    property int controlHeight: Looks.control.regular
    readonly property int arrowHeight: root.controlHeight - 4

    property list<var> options: []
    property string current: ""
    property string value: root.options.find(option => option.value === root.current)?.label ?? root.current

    signal clicked
    signal selected(string value)

    readonly property bool bezeled: hover.hovered || press.pressed || menu.visible

    implicitHeight: root.controlHeight
    implicitWidth: Looks.control.popupLabelInset + label.implicitWidth + Looks.control.popupValueGap + root.controlHeight + Looks.control.popupTrailingInset

    Rectangle {
        anchors {
            fill: parent
            rightMargin: Looks.control.popupTrailingInset
        }
        visible: root.bezeled
        radius: Looks.controlRadius(root.controlHeight)
        antialiasing: true
        color: press.pressed ? Looks.surfaces.buttonBorderedPressed : Looks.surfaces.buttonBordered
    }

    MText {
        id: label
        anchors {
            right: chevron.left
            rightMargin: Looks.control.popupValueGap
            verticalCenter: parent.verticalCenter
        }
        text: root.value
        font.styleName: Looks.font.rendered(Looks.font.controlStyleName)
    }

    Item {
        id: chevron
        anchors {
            right: parent.right
            rightMargin: Looks.control.popupTrailingInset
            verticalCenter: parent.verticalCenter
        }
        width: root.controlHeight
        height: root.controlHeight

        Rectangle {
            anchors.centerIn: parent
            visible: !root.bezeled
            width: root.arrowHeight
            height: root.arrowHeight
            radius: height / 2
            antialiasing: true
            color: Looks.surfaces.buttonBordered
        }

        MSymbol {
            anchors.centerIn: parent
            symbol: "chevron.up.chevron.down"
            height: root.arrowHeight * 0.52
            color: Looks.colors.primary
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    MouseArea {
        id: press
        anchors.fill: parent
        onClicked: {
            root.clicked();
            if (root.options.length === 0)
                return;
            menu.x = root.width - Looks.control.popupTrailingInset - menu.width;
            menu.y = root.height + 4;
            menu.open();
        }
    }

    MMenu {
        id: menu
        minimumWidth: 170
        entries: root.options.map(option => ({
                    label: option.label,
                    checked: option.value === root.current,
                    value: option.value
                }))
        onActivated: entry => root.selected(entry.value)
    }
}
