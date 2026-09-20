import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets

RippleButton {
    id: root

    visible: ScreenRecording.active
    implicitHeight: 26
    horizontalPadding: 8
    verticalPadding: 0
    buttonRadius: Appearance.rounding.full
    colBackground: Appearance.colors.colError
    colBackgroundHover: Appearance.colors.colErrorHover
    colRipple: Appearance.colors.colErrorActive
    onClicked: ScreenRecording.stop()

    contentItem: RowLayout {
        spacing: 4

        MaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            fill: 1
            text: "stop_circle"
            iconSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnError
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            Layout.topMargin: -1
            text: ScreenRecording.elapsed
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colOnError
        }
    }

    PopupToolTip {
        text: Translation.tr("Stop the recording")
        anchorEdges: (!Config.options.bar.bottom && !Config.options.bar.vertical) ? Edges.Bottom : Edges.Top
    }
}
