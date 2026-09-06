pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.controls
import qs.modules.macos.looks

MSettingsGroup {
    id: root

    required property var pane

    title: qsTr("Luminance")

    component LuminanceRow: MSettingsRow {
        id: entry

        required property string key
        property real from: 0
        property real to: 10000
        property real step: 1
        property int decimals: 0

        MNumberField {
            from: entry.from
            to: entry.to
            step: entry.step
            decimals: entry.decimals
            fieldWidth: entry.decimals > 0 ? 48 : 56
            value: root.pane.ruleNumber(entry.key)
            onEdited: level => root.pane.apply({
                [entry.key]: level
            })
        }
    }

    LuminanceRow {
        key: "sdrbrightness"
        label: qsTr("SDR brightness")
        detail: qsTr("How bright content that is not HDR is drawn while the display is in HDR.")
        wrapDetail: true
        from: 0
        to: 10
        step: 0.05
        decimals: 2
    }

    LuminanceRow {
        key: "sdrsaturation"
        label: qsTr("SDR saturation")
        from: 0
        to: 10
        step: 0.05
        decimals: 2
    }

    LuminanceRow {
        key: "sdr_min_luminance"
        label: qsTr("SDR minimum luminance")
        from: 0
        to: 1000
        step: 0.1
        decimals: 2
    }

    LuminanceRow {
        key: "sdr_max_luminance"
        label: qsTr("SDR maximum luminance")
        to: 10000
        step: 10
    }

    LuminanceRow {
        key: "min_luminance"
        label: qsTr("Display minimum luminance")
        from: -1
        to: 1000
        step: 0.1
        decimals: 2
    }

    LuminanceRow {
        key: "max_luminance"
        label: qsTr("Display maximum luminance")
        from: -1
        step: 10
    }

    LuminanceRow {
        key: "max_avg_luminance"
        label: qsTr("Display maximum average luminance")
        from: -1
        step: 10
    }

    MSettingsRow {
        separator: false
        note: qsTr("A display luminance of −1 leaves the figure to what the display reports.")
    }
}
