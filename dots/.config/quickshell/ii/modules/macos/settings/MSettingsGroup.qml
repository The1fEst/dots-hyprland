pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

// The inset rounded box macOS groups settings rows into.
Column {
    id: root

    property string title: ""

    default property alias rows: content.data

    spacing: 6

    MText {
        x: Looks.settings.formRowInset
        visible: root.title.length > 0
        text: root.title
        emphasized: true
        color: Looks.colors.primary
    }

    Rectangle {
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
