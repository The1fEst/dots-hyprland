pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import qs.modules.macos.controls
import qs.modules.macos.looks

// The modal card macOS drops over a settings pane: a group of rows, then a rule and a
// button bar under it.
Popup {
    id: root

    property string confirmLabel: qsTr("OK")
    property string cancelLabel: qsTr("Cancel")
    property bool confirmEnabled: true

    default property alias rows: card.rows

    signal confirmed
    signal cancelled

    width: Looks.settings.sheetWidth
    padding: Looks.settings.sheetPadding
    modal: true
    dim: true
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape

    background: Rectangle {
        radius: Looks.radius.window
        color: Looks.surfaces.panel
        antialiasing: true
    }

    contentItem: Column {
        spacing: 0

        MSettingsGroup {
            id: card
            width: parent.width
        }

        Item {
            width: parent.width
            height: Looks.settings.sheetFooterGap
        }

        // The rule runs the full width of the sheet, past the padding the rows keep.
        Rectangle {
            x: -root.padding
            width: root.width
            height: 1
            color: Looks.colors.divider
        }

        Item {
            width: parent.width
            height: Looks.settings.sheetFooterHeight

            Row {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                spacing: 12

                MPushButton {
                    controlHeight: Looks.control.large
                    minimumWidth: Looks.settings.sheetButtonWidth
                    label: root.cancelLabel
                    onClicked: {
                        root.close();
                        root.cancelled();
                    }
                }

                MPushButton {
                    controlHeight: Looks.control.large
                    minimumWidth: Looks.settings.sheetButtonWidth
                    label: root.confirmLabel
                    prominent: true
                    opacity: root.confirmEnabled ? 1 : 0.4
                    onClicked: {
                        if (!root.confirmEnabled)
                            return;
                        root.close();
                        root.confirmed();
                    }
                }
            }
        }
    }
}
