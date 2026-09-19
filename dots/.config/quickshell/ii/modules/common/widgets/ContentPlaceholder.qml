import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets

/**
 * A whole-page state instead of a list: what is missing and what to do about it.
 */
Item {
    id: root

    property alias icon: placeholder.icon
    property alias title: placeholder.title
    property alias description: placeholder.description

    Layout.fillWidth: true
    implicitHeight: 220

    PagePlaceholder {
        id: placeholder
        descriptionHorizontalAlignment: Text.AlignHCenter
    }
}
