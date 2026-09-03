pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.controls
import qs.modules.macos.looks

// One line in a group: a label on the left, whatever the setting needs on the right.
Item {
    id: root

    property string label: ""
    property bool emphasizedLabel: false
    property bool wrapLabel: false
    property string detail: ""

    // macOS lets the explanatory line under a heading run to two or three lines; a plain
    // setting keeps its second line to one.
    property bool wrapDetail: false

    // The coloured status dot that precedes a state line.
    property color dot: "transparent"

    // The common shape: a name on the left and a read-only value on the right.
    property string value: ""

    // A row that leads somewhere carries a tinted glyph and a chevron.
    property string icon: ""
    property color iconTint: Looks.colors.gray
    property bool chevron: false

    property bool separator: true

    // A row that stands for a choice draws its own tick, and reserves the column for it on
    // every row of the list so the unticked ones line up with the ticked one.
    property bool selectable: false
    property bool selected: false

    // Rows that only reveal a control under the pointer read this rather than each of them
    // laying its own mouse area over the row. A handler rather than the mouse area below,
    // which a control in the trailing slot would take the hover away from.
    readonly property alias hovered: pointerWatch.hovered

    default property alias control: controlSlot.data

    readonly property real padding: Looks.settings.formRowPadding
    readonly property real inset: Looks.settings.formRowInset

    // A glyph drawn as a control carries its own bezel, so a row trailing one sits further
    // from the edge than a row trailing a button does.
    property real controlInset: Looks.settings.formRowInset

    // The label block sits in the middle of the row: padding only sets the floor, and a
    // row that stays at its minimum height would otherwise carry its single line high.
    readonly property real contentHeight: Math.max(labels.height, badge.visible ? badge.height : 0)
    readonly property real contentTop: Math.round((root.height - root.contentHeight) / 2)

    // Trailing controls line up with the label, not with the row: a row whose detail wraps
    // to three lines still shows its switch beside the heading.
    readonly property real headCenter: root.contentTop + Looks.font.style.body.lineHeight / 2

    implicitWidth: parent?.width ?? 0
    implicitHeight: Math.max(Looks.settings.formRowHeight, root.padding * 2 + root.contentHeight)

    MIconBadge {
        id: badge
        x: root.inset
        y: root.contentTop
        visible: root.icon.length > 0
        tint: root.iconTint
        symbol: root.icon
        badgeSize: Looks.settings.formRowIconSize
        badgeRadius: Looks.settings.formRowIconRadius
    }

    Column {
        id: labels
        x: badge.visible ? badge.x + badge.width + Looks.settings.formRowIconGap : root.inset
        y: root.contentTop
        width: Math.max(0, root.width - x - controlSlot.width - root.inset - Looks.settings.formRowIconGap)
        spacing: Looks.settings.formRowLabelGap

        Row {
            id: labelRow
            spacing: 6

            Item {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.selectable
                width: Looks.settings.formRowTickSlot - labelRow.spacing
                height: Looks.font.style.body.lineHeight

                MSymbol {
                    anchors.centerIn: parent
                    visible: root.selected
                    symbol: "checkmark"
                    symbolSize: 11
                    color: Looks.colors.primary
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.dot.a > 0 && root.detail.length === 0
                width: Looks.settings.formRowDotSize
                height: width
                radius: width / 2
                color: root.dot
                antialiasing: true
            }

            MText {
                readonly property real available: labels.width - (root.dot.a > 0 && root.detail.length === 0 ? Looks.settings.formRowDotSize + labelRow.spacing : 0) - (root.selectable ? Looks.settings.formRowTickSlot : 0)

                text: root.label
                emphasized: root.emphasizedLabel
                color: Looks.colors.primary
                elide: root.wrapLabel ? Text.ElideNone : Text.ElideRight
                wrapMode: root.wrapLabel ? Text.WordWrap : Text.NoWrap
                lineHeight: Looks.font.style.body.lineHeight
                lineHeightMode: Text.FixedHeight
                height: root.wrapLabel ? implicitHeight : Looks.font.style.body.lineHeight
                width: root.wrapLabel ? available : Math.min(implicitWidth, available)
            }
        }

        // The status dot belongs to the state, so it leads the detail wherever there is
        // one and falls back to the label when the state is all the row says.
        Row {
            id: detailRow
            visible: root.detail.length > 0
            spacing: 6

            Rectangle {
                y: Math.round((Looks.font.style.subheadline.lineHeight - height) / 2)
                visible: root.dot.a > 0
                width: Looks.settings.formRowDotSize
                height: width
                radius: width / 2
                color: root.dot
                antialiasing: true
            }

            MText {
                text: root.detail
                textStyle: Looks.font.style.subheadline
                lineHeight: Looks.font.style.subheadline.lineHeight
                lineHeightMode: Text.FixedHeight
                color: Looks.colors.secondary
                elide: root.wrapDetail ? Text.ElideNone : Text.ElideRight
                wrapMode: root.wrapDetail ? Text.WordWrap : Text.NoWrap
                width: labels.width - (root.dot.a > 0 ? Looks.settings.formRowDotSize + detailRow.spacing : 0)
            }
        }
    }

    HoverHandler {
        id: pointerWatch
    }

    MSymbol {
        anchors.right: parent.right
        anchors.rightMargin: root.inset
        y: root.headCenter - height / 2
        visible: root.chevron
        symbol: "chevron.right"
        symbolSize: 12
        color: Looks.colors.tertiary
    }

    MText {
        anchors.right: parent.right
        anchors.rightMargin: root.inset
        y: root.headCenter - height / 2
        visible: root.value.length > 0
        text: root.value
        color: Looks.colors.secondary
    }

    Item {
        id: controlSlot
        anchors.right: parent.right
        anchors.rightMargin: root.controlInset
        y: root.headCenter - height / 2
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
        width: implicitWidth
        height: implicitHeight
    }

    // Inset from the label, the way macOS runs its dividers.
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: root.inset
            rightMargin: root.inset
        }
        visible: root.separator
        height: 1
        color: Looks.colors.divider
    }
}
