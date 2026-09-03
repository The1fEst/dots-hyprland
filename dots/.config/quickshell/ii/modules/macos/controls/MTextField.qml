pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.looks

// The borderless entry a form row carries in its trailing slot: no bezel, just a caret
// where the value goes.
FocusScope {
    id: root

    property alias text: input.text
    property alias echoMode: input.echoMode
    property string placeholder: ""
    property real fieldWidth: 180

    implicitWidth: root.fieldWidth
    implicitHeight: Looks.font.style.body.lineHeight

    TextInput {
        id: input
        anchors.fill: parent
        focus: true
        clip: true
        verticalAlignment: Text.AlignVCenter
        // The value grows back from the trailing edge, which is where the row's other
        // controls sit and where the caret rests before anything is typed.
        horizontalAlignment: Text.AlignRight
        font.family: Looks.font.text
        font.pixelSize: Looks.font.style.body.size
        color: Looks.colors.primary
        selectionColor: Looks.accent
        selectedTextColor: "#ffffff"

        MText {
            anchors.fill: parent
            visible: input.text.length === 0
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text: root.placeholder
            color: Looks.colors.tertiary
        }
    }
}
