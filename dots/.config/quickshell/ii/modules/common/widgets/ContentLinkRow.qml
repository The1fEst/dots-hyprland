import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

/**
 * A row that stands for a page of its own: it says what is behind it and opens it.
 */
RippleButton {
    id: root

    property string buttonIcon: ""
    property string title: ""
    property string subtitle: ""

    Layout.fillWidth: true
    implicitHeight: 56
    horizontalPadding: 12
    buttonRadius: Appearance.rounding.small
    colBackground: Appearance.colors.colLayer2

    contentItem: RowLayout {
        spacing: 12

        OptionalMaterialSymbol {
            icon: root.buttonIcon
            iconSize: Appearance.font.pixelSize.larger
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: root.title
                elide: Text.ElideRight
                color: Appearance.colors.colOnLayer2
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.subtitle.length > 0
                text: root.subtitle
                elide: Text.ElideRight
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
            }
        }

        MaterialSymbol {
            text: "chevron_right"
            iconSize: Appearance.font.pixelSize.larger
            color: Appearance.colors.colSubtext
        }
    }
}
