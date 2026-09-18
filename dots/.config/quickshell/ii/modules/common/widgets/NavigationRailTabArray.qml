import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property int currentIndex: 0
    property bool expanded: false
    default property alias tabData: tabBarColumn.data  
    implicitHeight: tabBarColumn.implicitHeight
    implicitWidth: tabBarColumn.implicitWidth
    Layout.topMargin: 25

    readonly property var tabItems: {
        const buttons = [];
        for (let i = 0; i < tabBarColumn.children.length; i++) {
            const child = tabBarColumn.children[i];
            if (child instanceof NavigationRailButton)
                buttons.push(child);
        }
        return buttons;
    }
    readonly property Item currentItem: root.tabItems[root.currentIndex] ?? null

    Rectangle {
        property real itemHeight: root.currentItem?.baseSize ?? 56
        property real highlightHeight: root.currentItem?.baseHighlightHeight ?? 56
        visible: root.currentItem !== null
        anchors.left: tabBarColumn.left
        y: (root.currentItem?.y ?? 0) + (root.expanded ? 0 : ((itemHeight - highlightHeight) / 2))
        radius: Appearance.rounding.full
        color: Appearance.colors.colSecondaryContainer
        implicitHeight: root.expanded ? itemHeight : highlightHeight
        implicitWidth: root.currentItem?.visualWidth ?? 100

        Behavior on y {
            NumberAnimation {
                duration: Appearance.animationCurves.expressiveFastSpatialDuration
                easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }
    }

    ColumnLayout {
        id: tabBarColumn
        anchors.fill: parent
        spacing: 0
    }
}
