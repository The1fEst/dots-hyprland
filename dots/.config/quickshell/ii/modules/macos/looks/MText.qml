import QtQuick

Text {
    id: root

    property bool emphasized: false
    property bool display: false

    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    color: Looks.colors.primary
    font {
        family: root.display ? Looks.font.display : Looks.font.text
        pixelSize: Looks.font.size.normal
        styleName: root.emphasized ? "Semibold" : "Regular"
    }
}
