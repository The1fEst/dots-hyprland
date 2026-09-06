pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.macos.controls
import qs.modules.macos.looks

MSettingsGroup {
    id: root

    required property var pane

    readonly property list<var> forced: [
        {
            label: qsTr("Automatic"),
            value: "0"
        },
        {
            label: qsTr("On"),
            value: "1"
        },
        {
            label: qsTr("Off"),
            value: "-1"
        }
    ]

    function fileName(path: string): string {
        return path.slice(path.lastIndexOf("/") + 1);
    }

    title: qsTr("Color")

    MSettingsRow {
        label: qsTr("Color profile")

        MPopupButton {
            current: root.pane.colorProfile
            options: root.pane.colorProfiles
            onSelected: value => root.pane.setColorProfile(value)
        }
    }

    MSettingsRow {
        label: qsTr("Bit depth")

        MPopupButton {
            current: String(root.pane.ruleNumber("bitdepth"))
            options: [
                {
                    label: qsTr("8-bit"),
                    value: "8"
                },
                {
                    label: qsTr("10-bit"),
                    value: "10"
                }
            ]
            onSelected: value => root.pane.apply({
                bitdepth: parseInt(value)
            })
        }
    }

    MSettingsRow {
        label: qsTr("Force wide color")

        MPopupButton {
            current: String(root.pane.ruleNumber("supports_wide_color"))
            options: root.forced
            onSelected: value => root.pane.apply({
                supports_wide_color: parseInt(value)
            })
        }
    }

    MSettingsRow {
        label: qsTr("Force HDR")
        detail: qsTr("Forcing this on a display that does not report HDR can leave the screen black.")
        wrapDetail: true

        MPopupButton {
            current: String(root.pane.ruleNumber("supports_hdr"))
            options: root.forced
            onSelected: value => root.pane.apply({
                supports_hdr: parseInt(value)
            })
        }
    }

    MSettingsRow {
        label: qsTr("SDR transfer function")

        MPopupButton {
            current: root.pane.ruleValue("sdr_eotf")
            options: [
                {
                    label: qsTr("Default"),
                    value: "default"
                },
                {
                    label: qsTr("Automatic"),
                    value: "auto"
                },
                {
                    label: qsTr("sRGB"),
                    value: "srgb"
                },
                {
                    label: qsTr("Gamma 2.2"),
                    value: "gamma22"
                },
                {
                    label: qsTr("Gamma 2.2, forced"),
                    value: "gamma22force"
                }
            ]
            onSelected: value => root.pane.apply({
                sdr_eotf: value
            })
        }
    }

    MSettingsRow {
        label: qsTr("ICC profile")
        detail: root.pane.iccProfiles.length > 0 ? "" : qsTr("No profiles found in the icc directories.")
        wrapDetail: true
        separator: false

        MPopupButton {
            current: root.pane.ruleValue("icc")
            value: root.pane.ruleValue("icc").length > 0 ? root.fileName(root.pane.ruleValue("icc")) : qsTr("None")
            options: [
                {
                    label: qsTr("None"),
                    value: ""
                }
            ].concat(root.pane.iccProfiles.map(path => ({
                        label: root.fileName(path),
                        value: path
                    })))
            onSelected: value => root.pane.apply({
                icc: value
            })
        }
    }
}
