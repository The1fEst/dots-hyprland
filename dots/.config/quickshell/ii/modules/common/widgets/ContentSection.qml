import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

ColumnLayout {
    id: root
    property string title
    property string icon: ""
    property bool busy: false
    default property alias contentData: sectionContent.data

    Layout.fillWidth: true
    spacing: 6

    RowLayout {
        visible: root.title.length > 0 || root.icon.length > 0
        spacing: 6
        OptionalMaterialSymbol {
            icon: root.icon
            iconSize: Appearance.font.pixelSize.hugeass
        }
        StyledText {
            text: root.title
            font.pixelSize: Appearance.font.pixelSize.larger
            font.weight: Font.Medium
            color: Appearance.colors.colOnSecondaryContainer
        }
        MaterialLoadingIndicator {
            Layout.leftMargin: 4
            visible: root.busy
            loading: root.busy
            implicitSize: 18
        }
    }

    ColumnLayout {
        id: sectionContent
        Layout.fillWidth: true
        spacing: 4

    }
}
