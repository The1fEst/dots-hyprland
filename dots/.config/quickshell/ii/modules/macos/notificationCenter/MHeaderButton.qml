pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    property string label: ""
    property string iconName: "close"
    property bool showLabel: false

    signal clicked

    readonly property bool hovered: hoverArea.containsMouse

    radius: height / 2
    implicitHeight: 22
    implicitWidth: root.showLabel ? labelText.implicitWidth + 20 : 22

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    MaterialSymbol {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: root.iconName
        iconSize: 14
        color: Looks.colors.secondary
        opacity: root.showLabel ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }
    }

    MText {
        id: labelText
        anchors.centerIn: parent
        text: root.label
        font.pixelSize: Looks.font.size.small
        color: Looks.colors.secondary
        opacity: root.showLabel ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
