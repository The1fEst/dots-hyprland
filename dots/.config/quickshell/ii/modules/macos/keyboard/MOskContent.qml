pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.macos.looks
import "../../ii/onScreenKeyboard/layouts.js" as Layouts

Item {
    id: root

    required property MGlassBackdrop backdrop

    readonly property var layouts: Layouts.byName
    // Labels follow whatever Hyprland is typing in, so switching the layout switches the
    // keys too; the configured one is only a fallback for layouts we have no keys for.
    readonly property string layoutName: {
        if (root.layouts.hasOwnProperty(HyprlandXkb.currentLayoutName))
            return HyprlandXkb.currentLayoutName;
        if (root.layouts.hasOwnProperty(Config.options?.osk.layout ?? ""))
            return Config.options.osk.layout;
        return Layouts.defaultLayout;
    }
    readonly property var layout: root.layouts[root.layoutName]

    implicitWidth: rows.implicitWidth
    implicitHeight: rows.implicitHeight

    ColumnLayout {
        id: rows
        anchors.fill: parent
        spacing: 6

        Repeater {
            model: root.layout.keys

            RowLayout {
                required property var modelData

                spacing: 6

                Repeater {
                    model: modelData

                    MOskKey {
                        required property var modelData

                        backdrop: root.backdrop
                        keyData: modelData
                    }
                }
            }
        }
    }
}
