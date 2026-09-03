import QtQuick

Text {
    id: root

    property bool emphasized: false
    property bool display: false

    // Named `textStyle` because Text already owns `style` for its outline/raised effect.
    property var textStyle: Looks.font.style.body

    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    color: Looks.colors.primary
    font {
        family: root.display ? Looks.font.display : Looks.font.text
        pixelSize: root.textStyle.size
        styleName: Looks.font.rendered(root.emphasized ? root.textStyle.emphasizedStyleName : root.textStyle.styleName)
    }
}
