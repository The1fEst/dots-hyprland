pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

Row {
    id: root

    property int controlHeight: Looks.control.regular

    // Each option is { label, value }. With none the button is a label and a chevron and
    // reports its clicks, for callers that put the choice somewhere else.
    property list<var> options: []
    property string current: ""
    property string value: root.options.find(option => option.value === root.current)?.label ?? root.current

    signal clicked
    signal selected(string value)

    spacing: Looks.control.popupValueGap

    MText {
        anchors.verticalCenter: parent.verticalCenter
        text: root.value
        font.styleName: Looks.font.rendered(Looks.font.controlStyleName)
    }

    Item {
        id: chevronSlot
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: arrow.implicitWidth + Looks.control.popupTrailingInset
        implicitHeight: arrow.implicitHeight

        MCircleButton {
            id: arrow
            controlHeight: root.controlHeight
            symbol: "chevron.up.chevron.down"
            symbolSize: root.controlHeight * 0.52
            onClicked: {
                root.clicked();
                if (root.options.length === 0)
                    return;
                menu.x = arrow.width - menu.width;
                menu.y = arrow.height + 4;
                menu.open();
            }
        }

        MMenu {
            id: menu
            parent: chevronSlot
            menuWidth: 170
            entries: root.options.map(option => ({
                        label: option.label,
                        checked: option.value === root.current,
                        value: option.value
                    }))
            onActivated: entry => root.selected(entry.value)
        }
    }
}
