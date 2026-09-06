pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.macos.controls
import qs.modules.macos.looks

Column {
    id: root

    readonly property string accent: Config.options?.appearance.palette.accentColor ?? ""

    readonly property list<color> accents: [Looks.colors.blue, Looks.colors.purple, Looks.colors.pink, Looks.colors.red, Looks.colors.orange, Looks.colors.yellow, Looks.colors.green, Looks.colors.gray]

    spacing: Looks.settings.formGap

    function seeds(hex: string): bool {
        return root.accent.toLowerCase() === hex.toLowerCase();
    }

    function setAccent(hex: string): void {
        const generate = ["bash", Quickshell.shellPath("scripts/colors/switchwall.sh")];
        const fromTheWallpaperInUse = ["--color", "clear", "--noswitch"];
        accentProc.exec(generate.concat(hex.length > 0 ? ["--color", hex] : fromTheWallpaperInUse));
    }

    Process {
        id: accentProc
    }

    function describe(font: var): string {
        if (!font?.family)
            return "";
        const style = font.style && font.style !== "Regular" ? font.style + " " : "";
        return `${font.family} ${style}${font.size}`;
    }

    MSettingsGroup {
        width: parent.width
        title: qsTr("Theme")

        MSettingsRow {
            label: qsTr("Color")

            Row {
                spacing: 4

                Column {
                    spacing: 4

                    MColorSwatch {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spectrum: true
                        selected: root.accent.length === 0
                        onClicked: root.setAccent("")
                    }

                    MText {
                        text: qsTr("Multicolor")
                        textStyle: Looks.font.style.subheadline
                    }
                }

                Repeater {
                    model: root.accents

                    MColorSwatch {
                        required property color modelData

                        color: modelData
                        selected: root.seeds(String(modelData))
                        onClicked: root.setAccent(String(modelData))
                    }
                }
            }
        }

        MSettingsRow {
            label: qsTr("GTK theme")

            MPopupButton {
                current: MAppearance.gtkTheme
                options: MAppearance.gtkThemes.map(name => ({
                            label: name,
                            value: name
                        }))
                onSelected: value => MAppearance.setThemes(value, MAppearance.qtStyle)
            }
        }

        MSettingsRow {
            label: qsTr("Qt style")
            separator: false

            MPopupButton {
                current: MAppearance.qtStyle
                options: MAppearance.qtStyles.map(name => ({
                            label: name,
                            value: name
                        }))
                onSelected: value => MAppearance.setThemes(MAppearance.gtkTheme, value)
            }
        }
    }

    MSettingsGroup {
        width: parent.width
        title: qsTr("Pointer")

        MSettingsRow {
            label: qsTr("Cursor")
            detail: qsTr("Applied to Wayland, XWayland, GTK and Qt at once.")
            wrapDetail: true

            MPopupButton {
                current: MAppearance.cursorTheme
                options: MAppearance.cursorThemes.map(name => ({
                            label: name,
                            value: name
                        }))
                onSelected: value => MAppearance.setCursor(value, MAppearance.cursorSize)
            }
        }

        MSettingsRow {
            label: qsTr("Size")
            separator: false

            MNumberField {
                from: 8
                to: 128
                value: MAppearance.cursorSize
                onEdited: size => MAppearance.setCursor(MAppearance.cursorTheme, size)
            }
        }
    }

    MSettingsGroup {
        width: parent.width
        title: qsTr("Icons")

        MSettingsRow {
            label: qsTr("Icon theme")
            detail: qsTr("Applied to GTK, Qt and the shell at once.")
            wrapDetail: true
            separator: false

            MPopupButton {
                current: MAppearance.iconTheme
                options: MAppearance.iconThemes.map(name => ({
                            label: name,
                            value: name
                        }))
                onSelected: value => MAppearance.setIcons(value)
            }
        }
    }

    MSettingsGroup {
        width: parent.width
        title: qsTr("Fonts")

        MFontRow {
            role: "general"
            label: qsTr("General")
            detail: qsTr("Applied to GTK, Qt and the shell at once.")
        }

        MFontRow {
            role: "fixed"
            label: qsTr("Fixed width")
        }

        MFontRow {
            role: "small"
            label: qsTr("Small")
        }

        MFontRow {
            role: "toolbar"
            label: qsTr("Toolbar")
        }

        MFontRow {
            role: "menu"
            label: qsTr("Menu")
        }

        MFontRow {
            role: "title"
            label: qsTr("Window title")
        }

        MSettingsRow {
            label: qsTr("All fonts")
            detail: qsTr("Sets the parts you tick on every role above, leaving fixed width alone.")
            wrapDetail: true
            separator: false

            MPushButton {
                label: qsTr("Adjust All…")
                onClicked: sheet.edit("all", MAppearance.fonts["general"] ?? ({
                            family: "",
                            style: "",
                            size: 10
                        }))
            }
        }
    }

    MFontSheet {
        id: sheet
        onChosen: (role, parts) => MAppearance.setFont(role, parts)
    }

    component MFontRow: MSettingsRow {
        id: fontRow

        required property string role

        readonly property var font: MAppearance.fonts[fontRow.role] ?? ({
                family: "",
                style: "",
                size: 10
            })

        Row {
            spacing: Looks.settings.formRowIconGap

            MText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.describe(fontRow.font)
                color: Looks.colors.secondary
                font.family: fontRow.font.family
                font.styleName: fontRow.font.style
            }

            MPushButton {
                label: qsTr("Select…")
                onClicked: sheet.edit(fontRow.role, fontRow.font)
            }
        }
    }
}
