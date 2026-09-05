pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.modules.macos.controls
import qs.modules.macos.looks

// The inset rounded box macOS groups settings rows into.
Column {
    id: root

    property string title: ""

    property bool busy: false

    default property alias rows: content.data

    spacing: 6

    Item {
        width: parent.width
        visible: root.title.length > 0
        height: heading.implicitHeight

        MText {
            id: heading
            x: Looks.settings.formRowInset
            text: root.title
            emphasized: true
            color: Looks.colors.primary
        }

        MSpinner {
            anchors {
                right: parent.right
                rightMargin: Looks.settings.formRowInset
                verticalCenter: heading.verticalCenter
            }
            running: root.busy
        }
    }

    ClippingRectangle {
        width: parent.width
        implicitHeight: content.implicitHeight
        radius: Looks.settings.formRadius
        // No border: the group is a 3% wash and nothing else, and the only rules inside
        // it are the separators the rows draw between themselves.
        color: Looks.colors.seximal
        antialiasing: true

        Column {
            id: content
            width: parent.width
        }
    }
}
