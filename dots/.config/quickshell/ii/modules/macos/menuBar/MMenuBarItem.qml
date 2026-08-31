import QtQuick
import qs.modules.macos.looks

Item {
    id: root

    property real horizontalPadding: 7
    property real minWidth: Looks.sizes.menuBarItemMinWidth
    property bool interactive: true
    property bool active: false
    readonly property bool highlighted: root.active || (root.interactive && mouseArea.pressed)

    signal clicked(var event)

    default property alias content: contentItem.data

    implicitWidth: Math.max(minWidth, contentItem.implicitWidth + horizontalPadding * 2)
    implicitHeight: Looks.sizes.menuBarHeight

    Rectangle {
        anchors {
            fill: parent
            topMargin: Looks.sizes.menuBarItemInset
            bottomMargin: Looks.sizes.menuBarItemInset
        }
        radius: height / 2
        color: root.highlighted ? Looks.colors.menuBarHighlight : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Looks.animation.fast
            }
        }
    }

    Row {
        id: contentItem
        anchors.centerIn: parent
        spacing: 5
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.interactive
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => root.clicked(event)
    }
}
