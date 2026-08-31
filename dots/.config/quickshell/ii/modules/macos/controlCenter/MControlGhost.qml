pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.common.widgets
import qs.modules.macos.looks

MGlass {
    id: root

    required property var info

    readonly property bool wide: root.width >= root.height * 1.6

    MaterialSymbol {
        id: icon
        anchors {
            left: root.wide ? parent.left : undefined
            leftMargin: 14
            horizontalCenter: root.wide ? undefined : parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        text: root.info?.icon ?? ""
        iconSize: 22
        color: Looks.colors.secondary
    }

    MText {
        visible: root.wide
        anchors {
            left: icon.right
            leftMargin: 12
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        text: root.info?.name ?? ""
        emphasized: true
        elide: Text.ElideRight
        color: Looks.colors.secondary
    }
}
